{
  nixpkgs,
  root,
  super,
}: let
  inherit (root) mkCommand;
  inherit (super) contextFreeDrv;
  inherit (builtins) readFile toFile;
in
  currentSystem: target: let
    pkgs = nixpkgs.legacyPackages.${currentSystem};

    provisoDrv = pkgs.substituteAll {
      src = ./build-proviso.sh;
      filter = ./build-filter.jq;
      extractor = ./build-uncached-extractor.sed;
    };
    proviso =
      # toFile ensures it get's build
      toFile provisoDrv.name
      (readFile (toString provisoDrv));

    args = {
      targetDrv = target.drvPath;
      inherit proviso;
    };
  in
    mkCommand currentSystem "build" "build it" [] ''
      # ${target}
      nix build ${contextFreeDrv target}
    ''
    args
