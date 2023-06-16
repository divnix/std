{
  nixpkgs,
  root,
}:
/*
Use the Files Blocktype for any text data.

Available actions:
  - explore
*/
let
  inherit (root) mkCommand;
in
  name: {
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
      (mkCommand currentSystem "explore" "interactively explore with bat" ''
        ${bat} ${file}
      '' {})
    ];
  }
