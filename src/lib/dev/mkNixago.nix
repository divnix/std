{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (requireInput "nixago" "github:nix-community/nixago" "std.lib.dev.mkNixago") dmerge nixago;

  l = inputs.nixpkgs.lib // builtins;
in
  configuration: let
    # implement a minimal numtide/devshell forward contract
    configuration' =
      configuration
      // {
        hook = configuration.hook or {};
        packages = configuration.packages or [];
        commands = configuration.commands or [];
        devshell = configuration.devshell or {};
      };
    # transparently extend config data with a functor
    __functor = self: {
      data ? {},
      hook ? {},
      packages ? [],
      commands ? [],
      devshell ? {},
      output ? null,
    }: let
      __passthru = self.__passthru or configuration';
      newSelf =
        __passthru
        // {
          data = dmerge.merge __passthru.data data;
          hook = l.recursiveUpdate __passthru.hook hook;
          packages = __passthru.packages ++ packages;
          commands = __passthru.commands ++ commands;
          devshell = l.recursiveUpdate __passthru.devshell devshell;
          output =
            if output != null
            then output
            else __passthru.output;
        };
    in
      (nixago.lib.make newSelf)
      // {
        # keep here, cause nixago.lib.make would strip them
        inherit __functor;
        __passthru = newSelf;
      };
  in
    __functor configuration' {}
