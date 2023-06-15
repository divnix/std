{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (import "${inputs.self}/deprecation.nix" inputs) warnWriteShellEntrypoint;
in {
  mkMicrovm = import ./ops/mkMicrovm.nix {
    inputs = requireInput "microvm" "github:astro/microvm.nix" "std.lib.ops.mkMicrovm";
  };

  mkOperable = import ./ops/mkOperable.nix {inherit inputs cell;};
  mkOperableScript = import ./ops/mkOperableScript.nix {inherit inputs cell;};
  mkSetup = import ./ops/mkSetup.nix {inherit inputs cell;};
  mkUser = import ./ops/mkUser.nix {inherit inputs cell;};
  writeScript = import ./ops/writeScript.nix {inherit inputs cell;};
  lazyDerivation = import ./ops/lazyDerivation.nix {inherit inputs cell;};

  mkOCI = import ./ops/mkOCI.nix {inherit inputs cell;};
  mkDevOCI = import ./ops/mkDevOCI.nix {inherit inputs cell;};
  mkStandardOCI = import ./ops/mkStandardOCI.nix {inherit inputs cell;};
}
