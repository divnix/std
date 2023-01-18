{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  mkCommand = import ./mkCommand.nix {inherit nixpkgs;};

  contextFreeDrv = target: l.unsafeDiscardStringContext target.drvPath;

  build = system: target:
    mkCommand system {
      name = "build";
      description = "build it";
      command = ''
        # ${target}
        nix build ${contextFreeDrv target}
      '';
      targetDrv = target.drvPath;
      proviso =
        # bash
        ''
          function proviso() {
            local -n input=$1
            local -n output=$2

            local drvs
            local -a uncached

            # FIXME: merge upstream to avoid any need for runtime context
            command nix build github:divnix/nix-uncached/v2.12.1

            drvs="$(command jq -r '.targetDrv | select(. != "null")' <<< "''${input[@]}")"

            mapfile -t uncached < <(command nix show-derivation $drvs | jq -r '.[].outputs.out.path' | result/bin/nix-uncached)

            if [[ -n ''${uncached[*]} ]]; then
              mapfile -t uncached < <(command nix show-derivation ''${uncached[@]} \
              | command jq -r '.| to_entries[] | select(.value|.env.preferLocalBuild != "1") | .key')
            fi

            if [[ -n ''${uncached[*]} ]]; then
              local list filtered

              list=$(command jq -ncR '[inputs]' <<< "''${uncached[@]}")
              filtered=$(command jq -c 'select([.targetDrv] | inside($p))' --argjson p "$list" <<< "''${input[@]}")

              output=$(command jq -cs '. += $p' --argjson p "$output" <<< "$filtered")
            fi
          }
        '';
    };

  run = system: target: let
    programName =
      target.meta.mainProgram
      or (l.getName target);
  in
    mkCommand system {
      name = "run";
      description = "run it";
      # this is the exact sequence mentioned by the `nix run` docs
      # and so should be compatible
      command = ''
        ${target.program or "${target}/bin/${programName}"} "$@"
      '';
    };
in {inherit build run;}
