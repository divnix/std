{root}:
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
      inputs,
    }: let
      file = toString target;
      pkgs = inputs.nixpkgs.${currentSystem};
    in [
      (mkCommand currentSystem "explore" "interactively explore with bat" [pkgs.bat] ''
        bat ${file}
      '' {})
    ];
  }
