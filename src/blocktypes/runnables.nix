{
  nixpkgs,
  mkCommand,
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
      system,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (import ./actions/build.nix target (mkCommand system "runnables"))
      (mkCommand system "runnables" {
        name = "run";
        description = "exec this target";
        command = import ./actions/run.nix {
          inherit target lib;
        };
      })
    ];
  };
in
  runnables
