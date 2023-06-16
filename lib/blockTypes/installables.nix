{
  nixpkgs,
  root,
  super,
}:
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
let
  inherit (root) mkCommand actions;
  inherit (super) addSelectorFunctor;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "installables";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (actions.build currentSystem target)
      # profile commands require a flake ref
      (mkCommand currentSystem "install" "install this target" ''
        # ${target}
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        nix profile install $PRJ_ROOT#${fragment}
      '' {})
      (mkCommand currentSystem "upgrade" "upgrade this target" ''
        # ${target}
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        nix profile upgrade $PRJ_ROOT#${fragment}
      '' {})
      (mkCommand currentSystem "remove" "remove this target" ''
        # ${target}
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        nix profile remove $PRJ_ROOT#${fragment}
      '' {})
      # TODO: use target. `nix bundle` requires a flake ref, but we may be able to use nix-bundle instead as a workaround
      (mkCommand currentSystem "bundle" "bundle this target" ''
        # ${target}
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        nix bundle --bundler github:Ninlives/relocatable.nix --refresh $PRJ_ROOT#${fragment}
      '' {})
      (mkCommand currentSystem "bundleImage" "bundle this target to image" ''
        # ${target}
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh $PRJ_ROOT#${fragment}
      '' {})
      (mkCommand currentSystem "bundleAppImage" "bundle this target to AppImage" ''
        # ${target}
        if test -z "$PRJ_ROOT"; then
          echo "PRJ_ROOT is not set. Action aborting."
          exit 1
        fi
        nix bundle --bundler github:ralismark/nix-appimage --refresh $PRJ_ROOT#${fragment}
      '' {})
    ];
  }
