{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
in {
  mkMicrovm = import ./ops/mkMicrovm.nix {
    inputs = requireInput "microvm" "github:astro/microvm.nix" "std.lib.ops.mkMicrovm";
  };

  writeShellEntrypoint = import ./ops/writeShellEntrypoint.nix {
    inputs = requireInput "n2c" "github:nlewo/nix2container" "std.lib.ops.writeShellEntrypoint";
  };

  mkOperable = import ./ops/mkOperable.nix {inherit inputs cell;};
  mkSetup = import ./ops/mkSetup.nix {inherit inputs cell;};
  mkUser = import ./ops/mkUser.nix {inherit inputs cell;};
  writeScript = import ./ops/writeScript.nix {inherit inputs cell;};

  mkOCI =   import ./ops/mkOCI.nix {
    inherit cell;
    inputs = requireInput "n2c" "github:nlewo/nix2container" "std.lib.ops.mkOCI";
  };
}
