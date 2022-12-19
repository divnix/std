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
      (import ./actions/build.nix target)
      {
        name = "run";
        description = "exec this target";
        command = let
          run =
            # this is the exact sequence mentioned by the `nix run` docs
            # and so should be compatible
            target.program
            or "${target}/bin/${target.meta.mainProgram
              or (target.pname
                or builtins.head (builtins.split "-" target.name))}";
        in
          run;
      }
    ];
  };
in
  runnables
