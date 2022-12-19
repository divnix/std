{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Installables Blocktype for targets that you want to
  make availabe for installation into the user's nix profile.

  Available actions:
    - install
    - upgrade
    - remove
    - build
    - bundle
    - bundleImage
    - bundleAppImage
  */
  installables = name: {
    __functor = import ./__functor.nix;
    inherit name;
    type = "installables";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (import ./actions/build.nix target)
      # profile commands require a flake ref
      {
        name = "install";
        description = "install this target";
        command = ''
          # ${target}
          nix profile install ${flake}#${fragment}
        '';
      }
      {
        name = "upgrade";
        description = "upgrade this target";
        command = ''
          # ${target}
          nix profile upgrade ${flake}#${fragment}
        '';
      }
      {
        name = "remove";
        description = "remove this target";
        command = ''
          # ${target}
          nix profile remove ${flake}#${fragment}
        '';
      }
      # TODO: use target. `nix bundle` requires a flake ref, but we may be able to use nix-bundle instead as a workaround
      {
        name = "bundle";
        description = "bundle this target";
        command = ''
          # ${target}
          nix bundle --bundler github:Ninlives/relocatable.nix --refresh ${flake}#${fragment}
        '';
      }
      {
        name = "bundleImage";
        description = "bundle this target to image";
        command = ''
          # ${target}
          nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh ${flake}#${fragment}
        '';
      }
      {
        name = "bundleAppImage";
        description = "bundle this target to AppImage";
        command = ''
          # ${target}
          nix bundle --bundler github:ralismark/nix-appimage --refresh ${flake}#${fragment}
        '';
      }
    ];
  };
in
  installables
