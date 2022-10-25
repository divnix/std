{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
in {
  mkShell = import ./dev/mkShell.nix {inherit inputs cell;};
  mkNixago = import ./dev/mkNixago.nix {inherit inputs cell;};

  mkMakes = import ./dev/mkMakes.nix {
    l = inputs.nixpkgs.lib // builtins;
    inputs = requireInput "makes" "github:fluidattacks/makes" "std.lib.dev.mkMakes";
  };
}
