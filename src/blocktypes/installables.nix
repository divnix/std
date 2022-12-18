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
      fragment,
      fragmentRelPath,
    }: [
      (import ./actions/build.nix fragment)
      {
        name = "install";
        description = "install this target";
        command = ''
          nix profile install "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "upgrade";
        description = "upgrade this target";
        command = ''
          nix profile upgrade "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "remove";
        description = "remove this target";
        command = ''
          nix profile remove "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "bundle";
        description = "bundle this target";
        command = ''
          nix bundle --bundler github:Ninlives/relocatable.nix --refresh "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "bundleImage";
        description = "bundle this target to image";
        command = ''
          nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "bundleAppImage";
        description = "bundle this target to AppImage";
        command = ''
          nix bundle --bundler github:ralismark/nix-appimage --refresh "$PRJ_ROOT#${fragment}
        '';
      }
    ];
  };
in
  installables
