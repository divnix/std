{
  inputs,
  cell,
}: let
  inherit (inputs) dmerge devshell nixago;
  nixpkgs = inputs.nixpkgs;

  l = nixpkgs.lib // builtins;
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
            acc = l.foldl l.recursiveUpdate {};
          in
            acc (
              []
              ++ (builtins.map (o: o.devshell) cfg.nixago)
              ++ [{startup.nixago-setup-hook = l.stringsWithDeps.noDepEntry (nixago.lib.makeAll cfg.nixago).shellHook;}]
            );
          packages = builtins.concatMap (o: o.packages) cfg.nixago;
          commands = builtins.concatMap (o: o.commands) cfg.nixago;
        };
      };
  in
    devshell.legacyPackages.mkShell {
      imports = [configuration nixagoModule];
    };

  mkNixago = configuration: let
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
      configData ? {},
      hook ? {},
      packages ? [],
      commands ? [],
      devshell ? {},
    }: let
      __passthru = self.__passthru or configuration';
      newSelf =
        __passthru
        // {
          configData = dmerge.merge __passthru.configData configData;
          hook = l.recursiveUpdate __passthru.hook hook;
          packages = __passthru.packages ++ packages;
          commands = __passthru.commands ++ commands;
          devshell = l.recursiveUpdate __passthru.devshell devshell;
        };
    in
      (nixago.lib.make newSelf)
      // {
        # keep here, cause nixago.lib.make would strip them
        inherit __functor;
        __passthru = newSelf;
      };
  in
    __functor configuration' {};

  fromMakesWith = inputs': let
    inputsChecked = assert l.assertMsg (builtins.hasAttr "makes" inputs')
    (
      l.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'makes' must be defined in the flake. See inputs above.
      ''
    );
    assert l.assertMsg (builtins.hasAttr "nixpkgs" inputs')
    (
      l.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'nixpkgs' must be defined in the flake. See inputs above.
      ''
    ); inputs';
    makes = l.fix (
      l.extends
      (
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
    l.customisation.callPackageWith makes;

  fromMicrovmWith = import ./fromMicrovmWith.nix {inherit nixpkgs;};

  writeShellEntrypoint = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "n2c" inputs')
    (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.writeShellEntrypoint', an input
        named 'n2c' (representing 'nlewo/nix2container') must be defined in the flake.
        See inputs above.
      ''
    ); inputs';
  in
    import ./writeShellEntrypoint.nix {
      inputs = inputsChecked;
      inherit cell;
    };

  mkOperable = import ./mkOperable.nix {inherit inputs cell;};
  mkSetup = import ./mkSetup.nix {inherit inputs cell;};
  mkUser = import ./mkUser.nix {inherit inputs cell;};
  writeScript = import ./writeScript.nix {inherit inputs cell;};

  mkOCI = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "n2c" inputs')
    (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.mkOCI', an input
        named 'n2c' (representing 'nlewo/nix2container') must be defined in the flake.
        See inputs above.
      ''
    ); inputs';
  in
    import ./mkOCI.nix {
      inputs = inputsChecked;
      inherit cell;
    };
}
