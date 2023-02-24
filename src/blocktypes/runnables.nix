{
  nixpkgs,
  mkCommand,
  sharedActions,
}: let
  lib = nixpkgs.lib // builtins;
  /*
  Use the Runnables Blocktype for targets that you want to
  make accessible with a 'run' action on the TUI.
  */
  runnables = name: {
    __functor = import ./__functor.nix;
    inherit name;
    type = "runnables";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (sharedActions.build currentSystem target)
      (sharedActions.run currentSystem target)
    ];
  };
in
  runnables
