{
  trivial,
  root,
  super,
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

      augment = target:
        lib.mapAttrs (_: v: (
          if v ? metadata && v.metadata ? labels
          then lib.recursiveUpdate v {metadata.labels.revision = checkedRev;}
          else v
        )) (builtins.removeAttrs target ["meta"]);

      # add git revision under metadata.labels.revision, if present
      manifestsWithGitRevision = target: let
        render = manifest: v: builtins.toFile "${manifest}.json" (builtins.unsafeDiscardStringContext (builtins.toJSON v));
      in
        triv.linkFarm "k8s-manifests" (lib.mapAttrs'
          (n: v: lib.nameValuePair "${n}.json" (render n v))
          (augment target));

      render = ''
        declare manifest_path="$PRJ_DATA_HOME/${manifest_path}"
        render() {
          echo "Buiding manifests..."
          echo
          rm -rf "$manifest_path"
          mkdir -p "$manifest_path"
          ln -s "${manifestsWithGitRevision target}"/* "$manifest_path"
          echo
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
        ${render}
        render
      '' {})
      (mkCommand currentSystem "diff" "Diff the manifests against the cluster" [pkgs.kubectl] ''
        ${render}
        render

        diff() {
          kubectl diff --server-side=true --field-manager="std-action-$(whoami)" \
            --filename "$manifest_path" --recursive;
        }

        diff
      '' {})
      (mkCommand currentSystem "apply" "Apply the manifests to K8s" [pkgs.kubectl] ''
        ${render}
        render

        diff() {
          kubectl diff --server-side=true --field-manager="std-action-$(whoami)" \
            --filename "$manifest_path" --recursive;
        }

        run() {
          kubectl apply --server-side=true --field-manager="std-action-$(whoami)" \
            --filename "$manifest_path" --recursive;
        }

        diff
        ${askUserToProceedSnippet "apply" "run"}
      '' {})
      (mkCommand currentSystem "explore" "Interactively explore the manifests" [pkgs.fx] ''
        fx ${
          builtins.toFile "explore-k8s-manifests.json"
          (builtins.unsafeDiscardStringContext (builtins.toJSON (augment target)))
        }
      '' {})
    ];
  }
