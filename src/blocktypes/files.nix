deSystemize: nixpkgs': let
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
    }: let
      l = nixpkgs.lib // builtins;
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
      builder = ["nix" "build" "--impure" "--json" "--no-link" "$PRJ_ROOT#${fragment}"];
      jq = ["|" "${nixpkgs.jq}/bin/jq" "-r" "'.[].outputs.out'"];
      bat = ["${nixpkgs.bat}/bin/bat"];
    in [
      {
        name = "explore";
        description = "interactively explore with bat";
        command = nixpkgs.writeShellScriptWithPrjRoot "explore" (l.concatStringsSep "\t" (bat ++ ["$("] ++ builder ++ jq ++ [")"]));
      }
    ];
  };
in
  files
