{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Installables Clade for targets that you want to
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
    inherit name;
    clade = "installables";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "install";
        description = "install this target";
        command = ''
          nix profile install ${flake}#${fragment}
        '';
      }
      {
        name = "upgrade";
        description = "upgrade this target";
        command = ''
          nix profile upgrade ${flake}#${fragment}
        '';
      }
      {
        name = "remove";
        description = "remove this target";
        command = ''
          nix profile remove ${flake}#${fragment}
        '';
      }
      {
        name = "build";
        description = "build this target";
        command = ''
          nix build ${flake}#${fragment}
        '';
      }
      {
        name = "bundle";
        description = "bundle this target";
        command = ''
          nix bundle --bundler github:Ninlives/relocatable.nix --refresh ${flake}#${fragment}
        '';
      }
      {
        name = "bundleImage";
        description = "bundle this target to image";
        command = ''
          nix bundle --bundler github:NixOS/bundlers#toDockerImage --refresh ${flake}#${fragment}
        '';
      }
      {
        name = "bundleAppImage";
        description = "bundle this target to AppImage";
        command = ''
          nix bundle --bundler github:ralismark/nix-appimage --refresh ${flake}#${fragment}
        '';
      }
    ];
  };
in
  installables
