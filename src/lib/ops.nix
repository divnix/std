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

  readYAML = import ./ops/readYAML.nix {inherit inputs cell;};

  mkOCI = import ./ops/mkOCI.nix {
    inputs = requireInput "n2c" "github:nlewo/nix2container" "std.lib.ops.mkOCI";
    inherit cell;
  };
  mkDevOCI = import ./ops/mkDevOCI.nix {
    inputs = requireInput "n2c" "github:nlewo/nix2container" "std.lib.ops.mkDevOCI";
    inherit cell;
  };
  mkStandardOCI = import ./ops/mkStandardOCI.nix {
    inputs = requireInput "n2c" "github:nlewo/nix2container" "std.lib.ops.mkStandardOCI";
    inherit cell;
  };
}
