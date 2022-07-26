{
  inputs,
  cell,
}: let
  nixpkgs = inputs.nixpkgs;
in {
  inherit (inputs.devshell.legacyPackages) mkShell;
  mkNixago = configuration:
    (inputs.nixago.lib.make configuration)
    // {
      # transparently extend config data with a functor
      __functor = _: extra: (inputs.nixago.lib.make (configuration
        // {
          configData = inputs.data-merge.merge configuration.configData extra;
        }));
      # implement a minimal numtide/devshell forward contract
      packages = configuration.packages or [];
      commands = configuration.commands or [];
    };

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
