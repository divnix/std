{
  inputs,
  cell,
}: let
  nixpkgs = inputs.nixpkgs;
in {
  mkShell = configuration: let
    nixagoModule = {
      config,
      lib,
      ...
    }:
      with lib; let
        cfg = config;
      in {
        options.nixago = mkOption {
          type = types.listOf types.attrs;
          default = [];
          apply = x: builtins.catAttrs "__passthru" x;
          description = "List of `std` Nixago pebbles to load";
        };

        config = mkIf (cfg.nixago != []) {
          devshell = let
            acc = nixpkgs.lib.foldl inputs.nixpkgs.lib.recursiveUpdate {};
          in
            acc (
              []
              ++ (builtins.map (o: o.devshell) cfg.nixago)
              ++ [{startup.nixago-setup-hook = nixpkgs.lib.stringsWithDeps.noDepEntry (inputs.nixago.lib.makeAll cfg.nixago).shellHook;}]
            );
          packages = builtins.concatMap (o: o.packages) cfg.nixago;
          commands = builtins.concatMap (o: o.commands) cfg.nixago;
        };
      };
  in
    inputs.devshell.legacyPackages.mkShell {
      imports = [configuration nixagoModule];
    };

  mkNixago = configuration: let
    # implement a minimal numtide/devshell forward contract
    configuration' =
      configuration
      // {
        packages = configuration.packages or [];
        commands = configuration.commands or [];
        devshell = configuration.devshell or {};
      };
    # transparently extend config data with a functor
    __functor = self: {
      configData ? {},
      packages ? [],
      commands ? [],
      devshell ? {},
    }: let
      __passthru = self.__passthru or configuration';
      newSelf =
        __passthru
        // {
          configData = inputs.data-merge.merge __passthru.configData configData;
          packages = __passthru.packages ++ packages;
          commands = __passthru.commands ++ commands;
          devshell = inputs.nixpkgs.lib.recursiveUpdate __passthru.devshell devshell;
        };
    in
      (inputs.nixago.lib.make newSelf)
      // {
        # keep here, cause nixago.lib.make would strip them
        inherit __functor;
        __passthru = newSelf;
      };
  in
    __functor configuration' {};

  fromMakesWith = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "makes" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'makes' must be defined in the flake. See inputs above.
      ''
    );
    assert nixpkgs.lib.assertMsg (builtins.hasAttr "nixpkgs" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'nixpkgs' must be defined in the flake. See inputs above.
      ''
    ); inputs';
    makes = nixpkgs.lib.fix (
      nixpkgs.lib.extends (
        _: _: {
          inherit (inputsChecked.nixpkgs) system;
          inputs = inputsChecked;
          __nixpkgs__ = nixpkgs;
          __nixpkgsSrc__ = nixpkgs.path;
        }
      )
      (
        import (inputsChecked.makes + /src/args/agnostic.nix) {inherit (inputsChecked.nixpkgs) system;}
      )
      .__unfix__
    );
  in
    nixpkgs.lib.customisation.callPackageWith makes;

  fromMicrovmWith = import ./fromMicrovmWith.nix {inherit nixpkgs;};
}
