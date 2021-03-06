{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Runnables Clade for targets that you want to
  make accessible with a 'run' action on the TUI.
  */
  runnables = name: {
    inherit name;
    clade = "runnables";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "run";
        description = "exec this target";
        command = ''
          nix run ${flake}#${fragment}
        '';
      }
    ];
  };
in
  runnables
