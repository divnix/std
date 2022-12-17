deSystemize: nixpkgs': let
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
    }: let
      l = nixpkgs.lib // builtins;
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
    in [
      (import ./actions/build.nix nixpkgs.writeShellScriptWithPrjRoot fragment)
      {
        name = "print-image";
        description = "print out the image name & tag";
        command = nixpkgs.writeShellScriptWithPrjRoot "print-image" ''
          echo
          echo "$(nix eval --raw "$PRJ_ROOT#${fragment}.imageName):$(nix eval --raw "$PRJ_ROOT#${fragment}.imageTag)"
        '';
      }
      {
        name = "publish";
        description = "copy the image to its remote registry";
        command = nixpkgs.writeShellScriptWithPrjRoot "publish" ''
          nix run "$PRJ_ROOT#${fragment}.copyToRegistry
        '';
      }
      {
        name = "copy-to-registry";
        description = "copy the image to its remote registry";
        command = nixpkgs.writeShellScriptWithPrjRoot "copy-to-registry" ''
          nix run "$PRJ_ROOT#${fragment}.copyToRegistry
        '';
      }
      {
        name = "copy-to-docker";
        description = "copy the image to the local docker registry";
        command = nixpkgs.writeShellScriptWithPrjRoot "copy-to-docker" ''
          nix run "$PRJ_ROOT#${fragment}.copyToDockerDaemon
        '';
      }
      {
        name = "copy-to-podman";
        description = "copy the image to the local podman registry";
        command = nixpkgs.writeShellScriptWithPrjRoot "copy-to-podman" ''
          nix run "$PRJ_ROOT#${fragment}.copyToPodman
        '';
      }
    ];
  };
in
  containers
