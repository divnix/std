{
  trivial,
  root,
  super,
  dmerge,
}:
/*
Use the `kubectl` Blocktype for rendering deployment manifests
for the Kubernetes Cluster scheduler. Each named attribtute-set under the
block contains a set of deployment manifests.

Available actions:
  - render
  - deploy
  - explore
*/
let
  inherit (root) mkCommand;
  inherit (super) addSelectorFunctor askUserToProceedSnippet;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "kubectl";

    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      inherit (inputs.nixpkgs) lib;
      pkgs = inputs.nixpkgs.${currentSystem};
      triv = trivial.${currentSystem};

      manifest_path = fragmentRelPath;

      checkedRev = inputs.std.std.errors.bailOnDirty ''
        Will not render manifests from a dirty tree.
        Otherwise we cannot keep good track of deployment history.''
      inputs.self.rev;

      usesKustomize = target ? kustomization || target ? Kustomization;

      augment = let
        amendIfExists = path: rhs: manifest:
          if true == lib.hasAttrByPath path manifest
          then amendAlways rhs manifest
          else manifest;

        amendAlways = rhs: manifest: dmerge manifest rhs;
      in
        target:
          lib.mapAttrs (
            key:
              lib.flip lib.pipe [
                # metadata
                (
                  manifest:
                    if manifest ? metadata.labels && manifest.metadata.labels == null
                    then lib.recursiveUpdate manifest {metadata.labels = {};}
                    else manifest
                )
                (
                  amendIfExists ["metadata"]
                  {
                    metadata.labels."app.kubernetes.io/version" = checkedRev;
                    metadata.labels."app.kubernetes.io/managed-by" = "std-kubectl";
                  }
                )
                (
                  if usesKustomize && (key == "kustomization" || key == "Kustomization")
                  # ensure a kustomization picks up the preprocessed resources
                  then
                    (manifest:
                      manifest
                      // {
                        resources =
                          map
                          (n: "${n}.json")
                          (builtins.attrNames (builtins.removeAttrs target ["meta" "Kustomization" "kustomization"]));
                      })
                  else lib.id
                )
              ]
          ) (builtins.removeAttrs target ["meta"]);

      generateManifests = target: let
        writeManifest = name: manifest:
          builtins.toFile name (builtins.unsafeDiscardStringContext (builtins.toJSON manifest));

        renderManifests = lib.mapAttrsToList (name: manifest: ''
          cp ${writeManifest name manifest} ${
            if name == "kustomization" || name == "Kustomization"
            then "Kustomization"
            else "${name}.json"
          }
        '');
      in
        triv.runCommandLocal "generate-k8s-manifests" {} ''
          mkdir -p $out
          cd $out
          ${lib.concatStrings (renderManifests (augment target))}
        '';

      build = ''
        declare manifest_path="$PRJ_DATA_HOME/${manifest_path}"
        build() {
          echo "Buiding manifests..."
          echo
          rm -rf "$manifest_path"
          mkdir -p "$(dirname "$manifest_path")"
          ln -s "${generateManifests target}" "$manifest_path"
          echo "Manifests built in: $manifest_path"
        }
      '';
    in [
      /*
      The `render` action will take this Nix manifest descrition, convert it to JSON,
      inject the git revision validate the manifest, after which it can be run or
      planned with the kubectl cli or the `deploy` action.
      */
      (mkCommand currentSystem "render" "Build the JSON manifests" [] ''
        ${build}
        build
      '' {})
      (mkCommand currentSystem "diff" "Diff the manifests against the cluster" [pkgs.kubectl pkgs.icdiff] ''
        ${build}
        build

        diff() {
          kubectl diff ${
          if usesKustomize
          then "--kustomize"
          else "--recursive --filename"
        } "$manifest_path/";
        }

        # GitHub case
        if [[ -v CI ]] && [[ -v BRANCH ]] && [[ -v OWNER_AND_REPO ]] && command gh > /dev/null ; then

          set +e # diff exits 1 if diff existed
          read -r -d "" DIFFSTREAM <<DIFF
        ## Standard DiffPost

        This PR would generate the following \`kubectl\` diff:

        <details><summary>Preview</summary>

        \`\`\`diff
        $(diff)
        \`\`\`

        </details>
        DIFF
          set -e # we're past the invocation of diff

          if ! gh pr --repo "$OWNER_AND_REPO" comment "$BRANCH" --edit-last -b "$DIFFSTREAM"; then
            echo "Make a first post ..."
            gh pr --repo "$OWNER_AND_REPO" comment "$BRANCH" -b "$DIFFSTREAM"
          fi
        else
          KUBECTL_EXTERNAL_DIFF="icdiff -N -r"
          export KUBECTL_EXTERNAL_DIFF
          diff
        fi
      '' {})
      (mkCommand currentSystem "apply" "Apply the manifests to K8s" [pkgs.kubectl pkgs.icdiff] ''
        ${build}
        build

        KUBECTL_EXTERNAL_DIFF="icdiff -N -r"
        export KUBECTL_EXTERNAL_DIFF

        diff() {
          kubectl diff --server-side=true --field-manager="std-action-$(whoami)" ${
          if usesKustomize
          then "--kustomize"
          else "--recursive --filename"
        } "$manifest_path/";

          return $?;
        }

        run() {
          kubectl apply --server-side=true --field-manager="std-action-$(whoami)" ${
          if usesKustomize
          then "--kustomize"
          else "--recursive --filename"
        } "$manifest_path/";
        }

        diff
        ret=$?
        if [[ $ret == 0 ]] || [[ $ret == 1 ]]; then
          ${askUserToProceedSnippet "apply" "run"}
        fi
      '' {})
      (mkCommand currentSystem "explore" "Interactively explore the manifests" [pkgs.fx] ''
        fx ${
          builtins.toFile "explore-k8s-manifests.json"
          (builtins.unsafeDiscardStringContext (builtins.toJSON (augment target)))
        }
      '' {})
    ];
  }
