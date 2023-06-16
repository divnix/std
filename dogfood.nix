{
  growOn,
  inputs,
  blockTypes,
  pick,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./cells;
  cellBlocks = [
    ## For downstream use

    # std
    (blockTypes.runnables "cli" {ci.build = true;})
    (blockTypes.functions "devshellProfiles")
    (blockTypes.functions "errors")
    (blockTypes.installables "packages" {ci.build = true;})

    # lib
    (blockTypes.functions "dev")
    (blockTypes.functions "ops")
    (blockTypes.nixago "cfg")

    # presets
    (blockTypes.data "templates")
    (blockTypes.nixago "nixago")

    ## For local use in the Standard repository

    # _automation
    (blockTypes.devshells "devshells" {ci.build = true;})
    (blockTypes.nixago "configs")
    (blockTypes.containers "containers")
    # (blockTypes.tasks "tasks") # TODO: implement properly

    # _tests
    (blockTypes.data "data")
    (blockTypes.files "files")
  ];
}
# Soil ("compatibile with the entire world")
{
  devShells = harvest inputs.self ["_automation" "devshells"];
  packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
  templates = pick inputs.self ["presets" "templates"];
}
