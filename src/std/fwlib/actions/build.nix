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
    pkgs = nixpkgs.${currentSystem};

    proviso = ./build-proviso.sh;

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
