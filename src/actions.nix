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
      proviso =
        l.toFile "build-proviso"
        # bash
        ''
          # FIXME: merge upstream to avoid any need for runtime context
          command nix build github:divnix/nix-uncached/v2.13.1

          local -a drvs
          eval "$(
            command jq --raw-output '
              "drvs=(\(map(.targetDrv|strings)|@sh))"
            ' <<< "$1"
          )"

          command jq --raw-output \
            --argjson checked "$(./result/bin/nix-uncached ''${drvs[@]})" \
          ' (
              $checked | with_entries(select(.value == [])) | keys
            ) as $cached
            | map(select(
              [.targetDrv] | IN($cached) | not
            ))
          ' <<< "$1"

          unset drvs
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
