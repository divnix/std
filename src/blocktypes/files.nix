{
  nixpkgs,
  mkCommand,
}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Files Blocktype for any text data.

  Available actions:
    - explore
  */
  files = name: {
    inherit name;
    type = "files";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      file = toString target;
      bat = "${nixpkgs.legacyPackages.${currentSystem}.bat}/bin/bat";
    in [
      (mkCommand currentSystem {
        name = "explore";
        description = "interactively explore with bat";
        command = ''
          ${bat} ${file}
        '';
      })
    ];
  };
in
  files
