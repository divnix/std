{
  inputs,
  scope,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) lib;
in
  inputs.cells.lib.dev.mkNixago {
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
      stages = lib.attrNames (removeAttrs d skip_attrs);
      stagesStr = lib.concatStringsSep " " stages;
    in ''
      # Install configured hooks
      for stage in ${stagesStr}; do
        ${lib.getExe nixpkgs.lefthook} add -f "$stage"
      done
    '';
  }
