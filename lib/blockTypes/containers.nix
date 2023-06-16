{
  nixpkgs,
  n2c,
  root,
  super,
}:
/*
Use the Containers Blocktype for OCI-images built with nix2container.

Available actions:
  - print-image
  - publish
  - load
*/
let
  inherit (root) mkCommand actions;
  inherit (super) addSelectorFunctor;
  inherit (builtins) readFile toFile;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "containers";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      inherit (n2c.packages.${currentSystem}) skopeo-nix2container;
      inherit (nixpkgs.legacyPackages.${currentSystem}) pkgs;

      provisoDrv = pkgs.substituteAll {
        src = ./containers-proviso.sh;
        filter = ./containers-publish-filter.jq;
      };
      proviso =
        # toFile ensures it get's build
        toFile provisoDrv.name
        (readFile (toString provisoDrv));

      tags' =
        builtins.toFile "${target.name}-tags.json" (builtins.concatStringsSep "\n" target.image.tags);
      copyFn = let
        skopeo = "skopeo --insecure-policy";
      in ''
        export PATH=${skopeo-nix2container}/bin:$PATH

        copy() {
          local uri prev_tag
          uri=$1
          shift

          for tag in $(<${tags'}); do
            if ! [[ -v prev_tag ]]; then
              ${skopeo} copy nix:${target} "$uri:$tag" "$@"
            else
              # speedup: copy from the previous tag to avoid superflous network bandwidth
              ${skopeo} copy "$uri:$prev_tag" "$uri:$tag" "$@"
            fi
            echo "Done: $uri:$tag"

            prev_tag="$tag"
          done
        }
      '';
    in [
      (actions.build currentSystem target)
      (mkCommand currentSystem "print-image" "print out the image.repo with all tags" ''
        echo
        for tag in $(<${tags'}); do
          echo "${target.image.repo}:$tag"
        done
      '' {})
      (mkCommand currentSystem "publish" "copy the image to its remote registry" ''
          ${copyFn}
          copy docker://${target.image.repo}
        '' {
          meta.image = target.image.name;
          inherit proviso;
        })
      (mkCommand currentSystem "load" "load image to the local docker daemon" ''
        ${copyFn}
        if command -v podman &> /dev/null; then
           echo "Podman detected: copy to local podman"
           copy containers-storage:${target.image.repo} "$@"
        fi
        if command -v docker &> /dev/null; then
           echo "Docker detected: copy to local docker"
           copy docker-daemon:${target.image.repo} "$@"
        fi
      '' {})
    ];
  }
