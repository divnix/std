std: inputs: let
  inherit (inputs) incl;
  inherit (inputs.paisano) pick harvest;
in
  std.growOn {
    inherit inputs;
    cellsFrom = incl ./src ["std" "lib"];
    cellBlocks = with std.blockTypes; [
      ## For downstream use

      # std
      (runnables "cli" {ci.build = true;})
      (functions "devshellProfiles")
      (functions "errors")
      (data "templates")

      # lib
      (functions "dev")
      (functions "ops")
      (nixago "cfg")
    ];
  }
  (std.grow {
    inherit inputs;
    cellsFrom = incl ./src ["local" "tests"];
    cellBlocks = with std.blockTypes; [
      ## For local use in the Standard repository
      # local
      (devshells "shells" {ci.build = true;})
      (nixago "configs")
      (containers "containers")
      (namaka "checks")
    ];
  })
  {
    # auxiliary outputs
    devShells = harvest inputs.self ["local" "shells"];
    packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
    templates = pick inputs.self ["std" "templates"];
    checks = pick inputs.self ["tests" "checks"];
  }
