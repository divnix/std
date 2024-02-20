inputs: let
  inherit (inputs) incl std;
  inherit (inputs.paisano) pick harvest;
in
  std.growOn {
    inherit inputs;
    cellsFrom = incl ./src ["local" "tests"];
    nixpkgsConfig = {allowUnfree = true;};
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
    cellsFrom = incl ./src ["std" "lib" "data"];
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
      (anything "cfg")
      (data "configs")
    ];
  })
  {
    packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
    templates = pick inputs.self ["std" "templates"];
  }
