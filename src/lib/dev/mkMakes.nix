let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes") nixpkgs makes;
  inherit (inputs.nixpkgs.lib) customisation fix extends;
in
  customisation.callPackageWith (fix (
    extends (
      _: _: {
        inherit inputs;
        inherit (nixpkgs) system;
        __nixpkgs__ = nixpkgs;
        __nixpkgsSrc__ = nixpkgs.path;
      }
    )
    (
      import (makes + /src/args/agnostic.nix) {inherit (nixpkgs) system;}
    )
    .__unfix__
  ))
