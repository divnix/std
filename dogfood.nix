{
  growOn,
  inputs,
  blockTypes,
  pick,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./src;
  cellBlocks = [
    ## For downstream use

    # std
    (blockTypes.runnables "cli" {ci.build = true;})
    (blockTypes.functions "devshellProfiles")
    (blockTypes.functions "errors")

    # lib
    (blockTypes.functions "dev")
    (blockTypes.functions "ops")
    (blockTypes.nixago "cfg")

    # presets
    (blockTypes.data "templates")
    (blockTypes.nixago "nixago")

    ## For local use in the Standard repository

    # local
    (blockTypes.devshells "shells" {ci.build = true;})
    (blockTypes.nixago "configs")
    (blockTypes.containers "containers")
    (blockTypes.anything "checks")
  ];
}
# Soil ("compatibile with the entire world")
{
  devShells = harvest inputs.self ["local" "shells"];
  packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
  templates = pick inputs.self ["std" "templates"];
  checks = pick inputs.self ["tests" "checks"];
}
