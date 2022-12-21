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
    __functor = import ./__functor.nix;
    inherit name;
    type = "containers";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (import ./actions/build.nix target)
      {
        name = "print-image";
        description = "print out the image name & tag";
        command = ''
          echo
          echo "${target.imageName}:${target.imageTag}"
        '';
      }
      {
        name = "publish";
        description = "copy the image to its remote registry";
        command = let
          image = target.imageRefUnsafe or "${target.imageName}:${target.imageTag}";
          # derive the same skopeo to avoid adding additional context
          skopeo = let
            lines = builtins.split "\n" target.copyToRegistry.text;
            line = builtins.head (builtins.filter (x: builtins.isString x && l.hasInfix "/bin/skopeo" x) lines);
            words = builtins.split " " line;
          in
            builtins.head words;
        in ''
          if ${skopeo} --insecure-policy inspect docker://${image} &> /dev/null; then
            echo "Image ${image} already exists."
          else
            ${target.copyToRegistry}/bin/copy-to-registry
          fi
        '';
      }
      {
        name = "copy-to-registry";
        description = "copy the image to its remote registry";
        command = ''
          ${target.copyToRegistry}/bin/copy-to-registry
        '';
      }
      {
        name = "copy-to-docker";
        description = "copy the image to the local docker registry";
        command = ''
          ${target.copyToDockerDaemon}/bin/copy-to-docker-daemon
        '';
      }
      {
        name = "copy-to-podman";
        description = "copy the image to the local podman registry";
        command = ''
          ${target.copyToPodman}/bin/copy-to-podman
        '';
      }
    ];
  };
in
  containers
