let
  inherit (inputs.cells.std.errors) requireInput;
in {
  mkMakes = import ./mkMakes.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes";
  };

  mkArion = import ./mkArion.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "arion" "github:hercules-ci/arion" "std.lib.dev.mkArion";
  };
}
