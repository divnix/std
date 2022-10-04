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
}
