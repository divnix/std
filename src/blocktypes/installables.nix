{
  nixpkgs,
  mkCommand,
  sharedActions,
}: let
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
      fragment,
      fragmentRelPath,
      target,
    }: [
      (sharedActions.build system target)
      # profile commands require a flake ref
      (mkCommand system {
        name = "install";
        description = "install this target";
        command = ''
          # ${target}
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          nix profile install $PRJ_ROOT#${fragment}
        '';
      })
      (mkCommand system {
        name = "upgrade";
        description = "upgrade this target";
        command = ''
          # ${target}
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          nix profile upgrade $PRJ_ROOT#${fragment}
        '';
      })
      (mkCommand system {
        name = "remove";
        description = "remove this target";
        command = ''
          # ${target}
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          nix profile remove $PRJ_ROOT#${fragment}
        '';
      })
      # TODO: use target. `nix bundle` requires a flake ref, but we may be able to use nix-bundle instead as a workaround
      (mkCommand system {
        name = "bundle";
        description = "bundle this target";
        command = ''
          # ${target}
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          nix bundle --bundler github:Ninlives/relocatable.nix --refresh $PRJ_ROOT#${fragment}
        '';
      })
      (mkCommand system {
        name = "bundleImage";
        description = "bundle this target to image";
        command = ''
          # ${target}
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh $PRJ_ROOT#${fragment}
        '';
      })
      (mkCommand system {
        name = "bundleAppImage";
        description = "bundle this target to AppImage";
        command = ''
          # ${target}
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          nix bundle --bundler github:ralismark/nix-appimage --refresh $PRJ_ROOT#${fragment}
        '';
      })
    ];
  };
in
  installables
