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
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: let
      builder = ["nix" "build" "--impure" "--json" "--no-link" "${flake}#${fragment}"];
      jq = ["|" "${nixpkgs.legacyPackages.${system}.jq}/bin/jq" "-r" "'.[].outputs.out'"];
      bat = ["${nixpkgs.legacyPackages.${system}.bat}/bin/bat"];
    in [
      {
        name = "explore";
        description = "interactively explore with bat";
        command = l.concatStringsSep "\t" (bat ++ ["$("] ++ builder ++ jq ++ [")"]);
      }
    ];
  };
in
  files
