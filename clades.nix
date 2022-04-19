{nixpkgs}: {
  runnables = name: {
    inherit name;
    clade = "runnables";
    actions = {
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
      flake,
      fragment,
    }: [
      {
        name = "write";
        description = "write to file";
        command = [
          "nix"
          "build"
          "--impure"
          "--json"
          "--no-link"
          "--expr"
          (builtins.readFile ./clades/data-write-action-expr.nix)
          "|"
          "jq"
          "-r"
          "'.[].outputs.out'"
        ];
      }
      {
        name = "explore";
        description = "interactively explore (requires: 'fx')";
        command = [
          "nix"
          "build"
          "--impure"
          "--expr"
          (builtins.readFile ./clades/data-write-action-expr.nix)
          "|"
          "jq"
          "-r"
          "'.[].outputs.out'"
          "|"
          "fx"
        ];
      }
    ];
  };
}
