{nixpkgs}: {
  runnables = name: {
    inherit name;
    clade = "runnables";
    actions = {
      system,
      flake,
      fragment,
    }: [
      {
        name = "run";
        description = "exec this target";
        command = ["nix" "run" "${flake}#${fragment}"];
      }
    ];
  };
  installables = name: {
    inherit name;
    clade = "installables";
    actions = {
      system,
      flake,
      fragment,
    }: [
      {
        name = "install";
        description = "install this target";
        command = ["nix" "profile" "install" "${flake}#${fragment}"];
      }
      {
        name = "upgrade";
        description = "upgrade this target";
        command = ["nix" "profile" "upgrade" "${flake}#${fragment}"];
      }
      {
        name = "remove";
        description = "remove this target";
        command = ["nix" "profile" "remove" fragment];
      }
    ];
  };
  functions = name: {
    inherit name;
    clade = "functions";
  };
  data = name: {
    inherit name;
    clade = "data";
    actions = {
      system,
      flake,
      fragment,
    }: let
      deps = [
        "nix"
        "build"
        "--no-link"
        "${nixpkgs.sourceInfo.outPath}#fx"
        ";"
        "nix"
        "build"
        "--no-link"
        "${nixpkgs.sourceInfo.outPath}#jq"
        ";"
      ];
      builder = ["nix" "build" "--impure" "--json" "--no-link" "--expr" expr];
      jq = ["|" "${nixpkgs.legacyPackages.${system}.jq}/bin/jq" "-r" "'.[].outputs.out'"];
      fx = ["|" "xargs" "cat" "|" "${nixpkgs.legacyPackages.${system}.fx}/bin/fx"];
      expr = nixpkgs.lib.strings.escapeShellArg ''
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
        command = deps ++ builder ++ jq;
      }
      {
        name = "explore";
        description = "interactively explore";
        command = deps ++ builder ++ jq ++ fx;
      }
    ];
  };
}
