deSystemize: nixpkgs': let
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
    }: let
      l = nixpkgs.lib // builtins;
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
    in [
      (import ./actions/build.nix nixpkgs.writeShellScriptWithPrjRoot fragment)
      {
        name = "install";
        description = "install this target";
        command = nixpkgs.writeShellScriptWithPrjRoot "install" ''
          nix profile install "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "upgrade";
        description = "upgrade this target";
        command = nixpkgs.writeShellScriptWithPrjRoot "upgrade" ''
          nix profile upgrade "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "remove";
        description = "remove this target";
        command = nixpkgs.writeShellScriptWithPrjRoot "remove" ''
          nix profile remove "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "bundle";
        description = "bundle this target";
        command = nixpkgs.writeShellScriptWithPrjRoot "bundle" ''
          nix bundle --bundler github:Ninlives/relocatable.nix --refresh "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "bundleImage";
        description = "bundle this target to image";
        command = nixpkgs.writeShellScriptWithPrjRoot "bundleImage" ''
          nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh "$PRJ_ROOT#${fragment}
        '';
      }
      {
        name = "bundleAppImage";
        description = "bundle this target to AppImage";
        command = nixpkgs.writeShellScriptWithPrjRoot "bundleAppImage" ''
          nix bundle --bundler github:ralismark/nix-appimage --refresh "$PRJ_ROOT#${fragment}
        '';
      }
    ];
  };
in
  installables
