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
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      inherit (nixpkgs.legacyPackages.${currentSystem}) pkgs;

      # if target ? __std_data_wrapper, then we need to unpack from `.data`
      json = pkgs.writeTextFile {
        name = "data.json";
        text = builtins.toJSON (
          if target ? __std_data_wrapper
          then target.data
          else target
        );
      };
      jq = ["${pkgs.jq}/bin/jq" "-r" "'.'" "${json}"];
      fx = ["|" "${pkgs.fx}/bin/fx"];
    in [
      (mkCommand currentSystem {
        name = "write";
        description = "write to file";
        command = "echo ${json}";
      })
      (mkCommand currentSystem {
        name = "explore";
        description = "interactively explore";
        command = l.concatStringsSep "\t" (jq ++ fx);
      })
    ];
  };
in
  data
