{
  nixpkgs,
  root,
  super,
}: let
  inherit (root) mkCommand;
  inherit (super) contextFreeDrv;
in
  currentSystem: target: let
    pkgs = nixpkgs.legacyPackages.${currentSystem};
    args = {
      targetDrv = target.drvPath;
      proviso = pkgs.substituteAll {
        src = ./build-proviso.sh;
        filter = ./build-filter.jq;
        extractor = ./build-uncached-extractor.sed;
      };
    };
  in
    mkCommand currentSystem "build" "build it" ''
      # ${target}
      nix build ${contextFreeDrv target}
    ''
    args
