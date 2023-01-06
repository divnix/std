out: mkCommand: let
  contextFreeDrv =
    builtins.unsafeDiscardStringContext out.drvPath;
in
  mkCommand {
    name = "build";
    description = "build this target";
    command = ''
      # ${out}
      nix build ${contextFreeDrv}
    '';
    targetDrv = out.drvPath;
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
  }
