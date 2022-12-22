{nixpkgs}: let
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
      system,
      fragment,
      fragmentRelPath,
      target,
    }: let
      file = toString target;
      bat = "${nixpkgs.legacyPackages.${system}.bat}/bin/bat";
    in [
      {
        name = "explore";
        description = "interactively explore with bat";
        command = ''
          ${bat} ${file}
        '';
      }
    ];
  };
in
  files
