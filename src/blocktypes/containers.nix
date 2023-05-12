{
  nixpkgs,
  n2c, # nix2container
  mkCommand,
  sharedActions,
}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Containers Blocktype for OCI-images built with nix2container.

  Available actions:
    - print-image
    - publish
    - load
  */
  containers = name: {
    __functor = import ./__functor.nix;
    inherit name;
    type = "containers";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      inherit (n2c.packages.${currentSystem}) skopeo-nix2container;
      img = builtins.unsafeDiscardStringContext target.imageName;
      tags = target.meta.tags or [(builtins.unsafeDiscardStringContext target.imageTag)];
      tags' =
        builtins.toFile "${target.name}-tags.json" (builtins.unsafeDiscardStringContext (builtins.concatStringsSep "\n" tags));
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
      (sharedActions.build currentSystem target)
      (mkCommand currentSystem {
        name = "print-image";
        description = "print out the image name with all tags";
        command = ''
          echo
          for tag in $(<${tags'}); do
            echo "${img}:$tag"
          done
        '';
      })
      (mkCommand currentSystem {
        name = "publish";
        description = "copy the image to its remote registry";
        command = ''
          ${copyFn}
          copy docker://${img}
        '';
        meta.images = map (tag: "${img}:${tag}") tags;
        proviso = let
          filter = ./container-publish-filter.jq;
        in
          l.toFile "container-proviso" ''
            function scopeo_inspect() {
              local image
              image="$1"
              if command skopeo inspect --insecure-policy "docker://$image" &>/dev/null; then
                echo "$image"
              fi
            }
            export -f scopeo_inspect

            command jq --raw-output \
              --from-file "${filter}" \
              --arg available "$(
                parallel -j0 scopeo_inspect ::: "$(
                   command jq --raw-output 'map(.meta.images[0]|strings)[]' <<< "$1"
                )"
              )" <<< "$1"

            unset -f scopeo_inspect
            unset images
          '';
      })
      (mkCommand currentSystem {
        name = "load";
        description = "load image to the local docker daemon";
        command = ''
          ${copyFn}
          if command -v podman &> /dev/null; then
             echo "Podman detected: copy to local podman"
             copy containers-storage:${img} "$@"
          fi
          if command -v docker &> /dev/null; then
             echo "Docker detected: copy to local docker"
             copy docker-daemon:${img} "$@"
          fi
        '';
      })
      (mkCommand currentSystem {
        name = "copy-to-registry";
        description = "deprecated: use 'publish' instead";
        command = "echo 'copy-to-registry' is deprecated; use 'publish' action instead && exit 1";
      })
      (mkCommand currentSystem {
        name = "copy-to-docker";
        description = "deprecated: use 'load' instead";
        command = "echo 'copy-to-docker' is deprecated; use 'load' action instead && exit 1";
      })
      (mkCommand currentSystem {
        name = "copy-to-podman";
        description = "deprecated: use 'load' instead";
        command = "echo 'copy-to-podman' is deprecated; use 'load' action instead && exit 1";
      })
    ];
  };
in
  containers
