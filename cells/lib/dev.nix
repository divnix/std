{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
in {
    mkShell = import ./dev/mkShell.nix {inherit inputs cell;};
    mkNixago = import ./dev/mkNixago.nix {inherit inputs cell;};

  mkMakes = import ./dev/mkMakes.nix {
    inputs = requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes";
  };
}
