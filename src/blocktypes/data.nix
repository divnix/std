deSystemize: nixpkgs': let
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
    }: let
      l = nixpkgs.lib // builtins;
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
      builder = ["nix" "build" "--impure" "--json" "--no-link" "--expr" expr];
      jq = ["|" "${nixpkgs.jq}/bin/jq" "-r" "'.[].outputs.out'"];
      fx = ["|" "xargs" "cat" "|" "${nixpkgs.fx}/bin/fx"];
      expr = l.strings.escapeShellArg ''
        let
          pkgs = (builtins.getFlake "${nixpkgs.path}").legacyPackages.${nixpkgs.system};
          this = (builtins.getFlake "$PRJ_ROOT").${fragment};
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
        command = nixpkgs.writeShellScriptWithPrjRoot "write" (l.concatStringsSep "\t" (builder ++ jq));
      }
      {
        name = "explore";
        description = "interactively explore";
        command = nixpkgs.writeShellScriptWithPrjRoot "explore" (l.concatStringsSep "\t" (builder ++ jq ++ fx));
      }
    ];
  };
in
  data
