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
    - copy-to-registry
    - copy-to-podman
    - copy-to-docker
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
      copy-to = "${skopeo-nix2container}/bin/skopeo --insecure-policy copy nix:${target}";
      img = builtins.unsafeDiscardStringContext target.imageName;
      tags = let
        tags' = target.meta.tags or [(builtins.unsafeDiscardStringContext target.imageTag)];
      in
        builtins.toFile "${target.name}-tags" (builtins.unsafeDiscardStringContext (builtins.concatStringsSep "\n" tags'));
    in [
      (sharedActions.build currentSystem target)
      (mkCommand currentSystem {
        name = "print-image";
        description = "print out the image name & tag";
        command = ''
          echo
          echo "${target.imageName}:${target.imageTag}"
        '';
      })
      (mkCommand currentSystem {
        name = "publish";
        description = "copy the image to its remote registry";
        command = ''
          for tag in $(<${tags}); do
            ${copy-to} "docker://${img}:$tag" "$@"
          done
        '';
        proviso =
          l.toFile "container-proviso"
          # bash
          ''
            function proviso() {
            local -n input=$1
            local -n output=$2

            local -a images
            local delim="$RANDOM"

            function get_images () {
              command nix show-derivation $@ \
              | command jq -r '.[].env.__provisory'
            }

            drvs="$(command jq -r '.actionDrv | select(. != "null")' <<< "''${input[@]}")"

            mapfile -t images < <(get_images $drvs)

            command cat << "$delim" > /tmp/check.sh
            #!/usr/bin/env bash
            if ! command skopeo inspect --insecure-policy "$1" &>/dev/null; then
            echo "$1" >> /tmp/no_exist
            fi
            $delim

            chmod +x /tmp/check.sh

            rm -f /tmp/no_exist

            echo "''${images[@]}" \
            | command xargs -n 1 -P 0 /tmp/check.sh

            declare -a filtered

            for i in "''${!images[@]}"; do
              if command grep "''${images[$i]}" /tmp/no_exist &>/dev/null; then
                filtered+=("''${input[$i]}")
              fi
            done

            output=$(command jq -cs '. += $p' --argjson p "$output" <<< "''${filtered[@]}")
            }
          '';

        provisory = target.meta.provisory or "${img}:${target.imageTag}";
      })
      (mkCommand currentSystem {
        name = "load";
        description = "load image to the local docker daemon";
        command = ''
          copy_tags() {
            local storage=$1
            shift

            for tag in $(<${tags}); do
              ${copy-to} "$storage:${img}:$tag" "$@"
            done
          }
          if command -v podman &> /dev/null; then
             ixecontainerho "Podman detected: copy to local podman"
             copy_tags containers-storage "$@"
          fi
          if command -v docker &> /dev/null; then
             echo "Docker detected: copy to local docker"
             copy_tags docker-daemon "$@"
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
