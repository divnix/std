{
  growOn,
  inputs,
  blockTypes,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./cells;
  cellBlocks = [
    ## For downstream use

    # std
    (blockTypes.runnables "cli")
    (blockTypes.functions "devshellProfiles")
    (blockTypes.functions "lib")
    (blockTypes.nixago "nixago")
    (blockTypes.installables "packages")

    # presets
    (blockTypes.data "templates")
    (blockTypes.nixago "nixago")

    ## For local use in the Standard repository

    # _automation
    (blockTypes.devshells "devshells")
    (blockTypes.nixago "nixago")
    # (blockTypes.tasks "tasks") # TODO: implement properly

    # _tests
    (blockTypes.data "data")
    (blockTypes.files "files")
  ];
} {
  devShells = harvest inputs.self ["_automation" "devshells"];
  packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
  templates = let
    r = harvest inputs.self ["presets" "templates"];
    r' = builtins.head (builtins.attrNames r);
  in
    r.${r'};
}
