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
    ];
  };
in
  installables
