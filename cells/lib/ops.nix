{
  inputs,
  cell,
}: let
  inherit (inputs.cells.std.errors) requireInput;
  inherit (inputs.nixpkgs) lib;
in {
  hashOfPath = path: baseNameOf (lib.head (lib.splitString "-" path));

  mkMicrovm = import ./ops/mkMicrovm.nix {
    inputs = requireInput "microvm" "github:astro/microvm.nix" "std.lib.ops.mkMicrovm";
  };

  mkOperable = import ./ops/mkOperable.nix {inherit inputs cell;};
  mkOperableScript = import ./ops/mkOperableScript.nix {inherit inputs cell;};
  mkSetup = import ./ops/mkSetup.nix {inherit inputs cell;};
  mkUser = import ./ops/mkUser.nix {inherit inputs cell;};
  writeScript = import ./ops/writeScript.nix {inherit inputs cell;};

  mkOCI = import ./ops/mkOCI.nix {inherit inputs cell;};
  mkDevOCI = import ./ops/mkDevOCI.nix {inherit inputs cell;};
  mkStandardOCI = import ./ops/mkStandardOCI.nix {inherit inputs cell;};

  revise = import ./ops/revise.nix {inherit inputs cell;};
  revisePackage = import ./ops/revisePackage.nix {inherit inputs cell;};
  reviseOCI = import ./ops/reviseOCI.nix {inherit inputs cell;};
}
