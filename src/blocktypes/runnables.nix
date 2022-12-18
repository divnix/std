{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Runnables Blocktype for targets that you want to
  make accessible with a 'run' action on the TUI.
  */
  runnables = name: {
    __functor = import ./__functor.nix;
    inherit name;
    type = "runnables";
    actions = {
      system,
      fragment,
      fragmentRelPath,
    }: [
      (import ./actions/build.nix fragment)
      {
        name = "run";
        description = "exec this target";
        command = ''
          nix run "$PRJ_ROOT#${fragment} -- "$@"
        '';
      }
    ];
  };
in
  runnables
