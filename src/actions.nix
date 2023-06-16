{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  mkCommand = import ./mkCommand.nix {inherit nixpkgs;};

  contextFreeDrv = target: l.unsafeDiscardStringContext target.drvPath;

  build = currentSystem: target:
    mkCommand currentSystem {
      name = "build";
      description = "build it";
      command = ''
        # ${target}
        nix build ${contextFreeDrv target}
      '';
      targetDrv = target.drvPath;
      proviso = pkgs.substituteAll {
        src = ./actions-proviso.sh;
        filter = ./build-filter.jq;
        extractor = ./build-uncached-extractor.sed;
      };
    };

  run = currentSystem: target: let
    programName =
      target.meta.mainProgram
      or (l.getName target);
  in
    mkCommand currentSystem {
      name = "run";
      description = "run it";
      # this is the exact sequence mentioned by the `nix run` docs
      # and so should be compatible
      command = ''
        ${target.program or "${target}/bin/${programName}"} "$@"
      '';
    };
in {inherit build run;}
