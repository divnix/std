{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Data Clade for json serializable data.

  Available actions:
    - write
    - explore

  For all actions is true:
    Nix-proper 'stringContext'-carried dependency will be realized
    to the store, if present.
  */
  data = name: {
    inherit name;
    clade = "data";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: let
      builder = ["nix" "build" "--impure" "--json" "--no-link" "--expr" expr];
      jq = ["|" "${nixpkgs.legacyPackages.${system}.jq}/bin/jq" "-r" "'.[].outputs.out'"];
      fx = ["|" "xargs" "cat" "|" "${nixpkgs.legacyPackages.${system}.fx}/bin/fx"];
      expr = l.strings.escapeShellArg ''
        let
          pkgs = (builtins.getFlake "${nixpkgs.sourceInfo.outPath}").legacyPackages.${system};
          this = (builtins.getFlake "${flake}").${fragment};
        in
          pkgs.writeTextFile {
            name = "data.json";
            text = builtins.toJSON this;
          }
      '';
    in [
      {
        name = "write";
        description = "write to file";
        command = l.concatStringsSep "\t" (builder ++ jq);
      }
      {
        name = "explore";
        description = "interactively explore";
        command = l.concatStringsSep "\t" (builder ++ jq ++ fx);
      }
    ];
  };
in
  data
