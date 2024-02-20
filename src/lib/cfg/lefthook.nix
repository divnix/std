let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;

  mkScript = stage:
    nixpkgs.writeScript "lefthook-${stage}" ''
      #!${nixpkgs.runtimeShell}
      [ "$LEFTHOOK" == "0" ] || ${lib.getExe nixpkgs.lefthook} run "${stage}" "$@"
    '';

  toStagesConfig = config:
    lib.removeAttrs config [
      "colors"
      "extends"
      "skip_output"
      "source_dir"
      "source_dir_local"
    ];
in {
  data = {};
  format = "yaml";
  output = "lefthook.yml";
  packages = [nixpkgs.lefthook];
  # Add an extra hook for adding required stages whenever the file changes
  hook.extra = config:
    lib.pipe config [
      toStagesConfig
      lib.attrNames
      (lib.map (stage: ''ln -sf "${mkScript stage}" ".git/hooks/${stage}"''))
      (stages:
        lib.optional (stages != []) "mkdir -p .git/hooks"
        ++ stages)
      (lib.concatStringsSep "\n")
    ];
}
