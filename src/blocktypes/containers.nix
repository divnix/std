{
  nixpkgs,
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
      system,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (sharedActions.build system target)
      (mkCommand system {
        name = "print-image";
        description = "print out the image name & tag";
        command = ''
          echo
          echo "${target.imageName}:${target.imageTag}"
        '';
      })
      (mkCommand system {
        name = "publish";
        description = "copy the image to its remote registry";
        command = let
          image = target.imageRefUnsafe or "${target.imageName}:${target.imageTag}";
        in ''
          # docker://${builtins.unsafeDiscardStringContext image}
          ${target.copyToRegistry}/bin/copy-to-registry
        '';
        proviso =
          # bash
          ''
            function proviso() {
            local -n input=$1
            local -n output=$2

            local -a images
            local delim="$RANDOM"

            function get_images () {
              command nix show-derivation $@ \
              | command jq -r '.[].env.text' \
              | command grep -o 'docker://\S*'
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
      })
      (mkCommand system {
        name = "copy-to-registry";
        description = "copy the image to its remote registry";
        command = ''
          ${target.copyToRegistry}/bin/copy-to-registry
        '';
      })
      (mkCommand system {
        name = "copy-to-docker";
        description = "copy the image to the local docker registry";
        command = ''
          ${target.copyToDockerDaemon}/bin/copy-to-docker-daemon
        '';
      })
      (mkCommand system {
        name = "copy-to-podman";
        description = "copy the image to the local podman registry";
        command = ''
          ${target.copyToPodman}/bin/copy-to-podman
        '';
      })
    ];
  };
in
  containers
