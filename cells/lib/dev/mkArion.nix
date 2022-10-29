{
  inputs,
  l,
}: let
  inherit (inputs) arion nixpkgs;
in
  module:
    arion.lib.eval {
      modules = [module];
      pkgs = nixpkgs;
    }
