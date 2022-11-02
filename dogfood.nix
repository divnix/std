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
    (blockTypes.runnables "cli" {ci.build = true;})
    (blockTypes.functions "devshellProfiles")
    (blockTypes.functions "lib")
    (blockTypes.functions "errors")
    (blockTypes.nixago "nixago")
    (blockTypes.installables "packages" {ci.build = true;})

    # lib
    (blockTypes.functions "dev")
    (blockTypes.functions "ops")

    # presets
    (blockTypes.data "templates")
    (blockTypes.nixago "nixago")

    ## For local use in the Standard repository

    # _automation
    (blockTypes.devshells "devshells" {ci.build = true;})
    (blockTypes.nixago "nixago")
    (blockTypes.containers "containers" {ci.publish = true;})
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
