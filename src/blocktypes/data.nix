{
  nixpkgs,
  mkCommand,
}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Data Blocktype for json serializable data.

  Available actions:
    - write
    - explore

  For all actions is true:
    Nix-proper 'stringContext'-carried dependency will be realized
    to the store, if present.
  */
  data = name: {
    inherit name;
    type = "data";
    actions = {
      system,
      fragment,
      fragmentRelPath,
      target,
    }: let
      inherit (nixpkgs.legacyPackages.${system}) pkgs;

      json = pkgs.writeTextFile {
        name = "data.json";
        text = builtins.toJSON target;
      };
      jq = ["${pkgs.jq}/bin/jq" "-r" "'.'" "${json}"];
      fx = ["|" "${pkgs.fx}/bin/fx"];
    in [
      (mkCommand system {
        name = "write";
        description = "write to file";
        command = "echo ${json}";
      })
      (mkCommand system {
        name = "explore";
        description = "interactively explore";
        command = l.concatStringsSep "\t" (jq ++ fx);
      })
    ];
  };
in
  data
