{
  root,
  super,
  nixpkgs,
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
  l = nixpkgs.lib // builtins;
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
      inputs,
    }: let
      escapedFragment = l.escapeShellArg fragment;
    in [
      (actions.build currentSystem target)
      # profile commands require a flake ref
      (mkCommand currentSystem "install" "install this target" [] ''
        # ${target}
        set -x
        nix profile install "$PRJ_ROOT#"${escapedFragment}
      '' {})
      (mkCommand currentSystem "upgrade" "upgrade this target" [] ''
        # ${target}
        set -x
        nix profile upgrade "$PRJ_ROOT#"${escapedFragment}
      '' {})
      (mkCommand currentSystem "remove" "remove this target" [] ''
        # ${target}
        set -x
        nix profile remove "$PRJ_ROOT#"${escapedFragment}
      '' {})
      # TODO: use target. `nix bundle` requires a flake ref, but we may be able to use nix-bundle instead as a workaround
      (mkCommand currentSystem "bundle" "bundle this target" [] ''
        # ${target}
        set -x
        nix bundle --bundler github:Ninlives/relocatable.nix --refresh "$PRJ_ROOT#"${escapedFragment}
      '' {})
      (mkCommand currentSystem "bundleImage" "bundle this target to image" [] ''
        # ${target}
        set -x
        nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh "$PRJ_ROOT#"${escapedFragment}
      '' {})
      (mkCommand currentSystem "bundleAppImage" "bundle this target to AppImage" [] ''
        # ${target}
        set -x
        nix bundle --bundler github:ralismark/nix-appimage --refresh "$PRJ_ROOT#"${escapedFragment}
      '' {})
    ];
  }
