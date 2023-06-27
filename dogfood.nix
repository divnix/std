std: inputs: let
  inherit (inputs) incl;
  inherit (inputs.paisano) pick harvest;
in
  # __std.init.<system> = [ ... ] is discarded
  # and thus doesn't show up in the CLI/TUI
  std.growOn {
    inherit inputs;
    cellsFrom = incl ./src ["local" "tests"];
    cellBlocks = with std.blockTypes; [
      ## For local use in the Standard repository
      # local
      (devshells "shells" {ci.build = true;})
      (nixago "configs")
      (containers "containers")
      (namaka "checks" {ci.check = true;})
    ];
  }
  {
    devShells = harvest inputs.self ["local" "shells"];
    checks = harvest inputs.self ["tests" "checks" "snapshots" "check"];
  }
  (std.grow {
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
  })
  {
    packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
    templates = pick inputs.self ["std" "templates"];
  }
