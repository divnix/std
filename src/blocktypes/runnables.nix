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
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (import ./actions/build.nix flake fragment)
      {
        name = "run";
        description = "exec this target";
        command = ''
          nix run ${flake}#${fragment} -- "$@"
        '';
      }
    ];
  };
in
  runnables
