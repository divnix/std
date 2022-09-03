{nixpkgs}: let
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
    inherit name;
    type = "containers";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "print-image";
        description = "print out the image name & tag";
        command = ''
          echo
          echo "$(nix eval --raw ${flake}#${fragment}.imageName):$(nix eval --raw ${flake}#${fragment}.imageTag)"
        '';
      }
      {
        name = "copy-to-registry";
        description = "copy the image to its remote registry";
        command = ''
          nix run ${flake}#${fragment}.copyToRegistry
        '';
      }
      {
        name = "copy-to-docker";
        description = "copy the image to the local docker registry";
        command = ''
          nix run ${flake}#${fragment}.copyToDockerDaemon
        '';
      }
      {
        name = "copy-to-podman";
        description = "copy the image to the local podman registry";
        command = ''
          nix run ${flake}#${fragment}.copyToPodman
        '';
      }
    ];
  };
in
  containers
