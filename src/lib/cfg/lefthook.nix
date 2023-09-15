let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in {
  data = {};
  format = "yaml";
  output = "lefthook.yml";
  packages = [nixpkgs.lefthook];
  hook.extra = d: let
    # Add an extra hook for adding required stages whenever the file changes
    skip_attrs = [
      "colors"
      "extends"
      "skip_output"
      "source_dir"
      "source_dir_local"
    ];
    stages = l.attrNames (l.removeAttrs d skip_attrs);
    stagesStr = l.concatStringsSep " " stages;
  in ''
    # Install configured hooks
    for stage in ${stagesStr}; do
      ${l.getExe nixpkgs.lefthook} add -f "$stage"
    done
  '';
}
