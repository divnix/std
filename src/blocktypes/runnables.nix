deSystemize: nixpkgs': let
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
    }: let
      nixpkgs = deSystemize system nixpkgs'.legacyPackages;
    in [
      (import ./actions/build.nix nixpkgs.writeShellScriptWithPrjRoot fragment)
      {
        name = "run";
        description = "exec this target";
        command = nixpkgs.writeShellScriptWithPrjRoot "run" ''
          nix run "$PRJ_ROOT#${fragment} -- "$@"
        '';
      }
    ];
  };
in
  runnables
