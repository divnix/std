{ inputs
, system
}:
let
  nixpkgs = inputs.nixpkgs;
in
{
  fromMakesWith = inputs': system': let
    inputsChecked =
      assert nixpkgs.lib.assertMsg (builtins.hasAttr "makes" inputs') (
        nixpkgs.lib.traceSeqN 1 inputs' ''

          In order to be able to use 'std.lib.<system>.std-fromMakesWith', an input
          named 'makes' must be defined in the flake. See inputs above.
        ''
      );
      inputs';
    makes = nixpkgs.lib.fix (
      nixpkgs.lib.extends (
        _: _: {
          inputs = inputsChecked;
          __nixpkgs__ = nixpkgs;
          __nixpkgsSrc__ = nixpkgs.path;
        }
      )
      (
        import (inputsChecked.makes + /src/args/agnostic.nix) { inherit (system'.host) system; }
      )
      .__unfix__
    );
  in
    nixpkgs.lib.customisation.callPackageWith makes;
}
