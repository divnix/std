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
      proviso = let
        filter = ./build-filter.jq;
        extractor = ./build-uncached-extractor.sed;
      in
        l.toFile "build-proviso"
        # bash
        ''
          function getUncachedDrvs {
            local -a uncached
            local drv
            drv=$1

            mapfile -t uncached < <(
              command nix-store --realise --dry-run "$drv" 2>&1 1>/dev/null \
              | command sed -nrf ${extractor}
            )

            test ''${#uncached[@]} -eq 0 && return;

            if (
               command nix show-derivation ''${uncached[@]} 2> /dev/null \
               | command jq --exit-status \
               ' with_entries(
                   select(.value|.env.preferLocalBuild != "1")
                 ) | any
               ' 1> /dev/null
            ); then
              echo "$drv"
            fi
          }

          export -f getUncachedDrvs

          command jq --raw-output \
            --from-file ${filter} \
            --arg uncachedDrvs "$(
              parallel -j0 getUncachedDrvs ::: "$(
                 command jq --raw-output 'map(.targetDrv|strings)[]' <<< "$1"
              )"
            )" <<< "$1"

          unset -f getUncachedDrvs
        '';
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
