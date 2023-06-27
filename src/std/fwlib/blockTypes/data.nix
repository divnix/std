{
  trivial,
  root,
}:
/*
Use the Data Blocktype for json serializable data.

Available actions:
  - write
  - explore

For all actions is true:
  Nix-proper 'stringContext'-carried dependency will be realized
  to the store, if present.
*/
let
  inherit (root) mkCommand;
  inherit (builtins) toJSON concatStringsSep;
in
  name: {
    inherit name;
    type = "data";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
      inputs,
    }: let
      inherit (inputs.nixpkgs.${currentSystem}) pkgs;
      triv = trivial.${currentSystem};

      # if target ? __std_data_wrapper, then we need to unpack from `.data`
      json = triv.writeTextFile {
        name = "data.json";
        text = toJSON (
          if target ? __std_data_wrapper
          then target.data
          else target
        );
      };
    in [
      (mkCommand currentSystem "write" "write to file" [] "echo ${json}" {})
      (mkCommand currentSystem "explore" "interactively explore" [pkgs.fx] (
        concatStringsSep "\t" ["fx" json]
      ) {})
    ];
  }
