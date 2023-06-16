{
  nixpkgs,
  root,
  super,
}:
/*
Use the Runnables Blocktype for targets that you want to
make accessible with a 'run' action on the TUI.
*/
let
  inherit (root) mkCommand actions;
  inherit (super) addSelectorFunctor;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "runnables";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (actions.build currentSystem target)
      (actions.run currentSystem target)
    ];
  }
