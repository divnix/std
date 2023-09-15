let
  inherit (inputs.std) findTargets;
in
  findTargets {
    inherit inputs cell;
    block = ./.;
  }
