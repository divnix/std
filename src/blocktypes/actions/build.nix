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
    proviso =
      # bash
      ''
        function proviso() {
          local -n input=$1
          local -n output=$2

          local drvs
          local -a uncached

          # FIXME: merge upstream to avoid any need for runtime context
          nix build github:divnix/nix-uncached/v2.12.1

          drvs="$(jq -r '.targetDrv | select(. != "null")' <<< "''${input[@]}")"

          mapfile -t uncached < <(nix-store -q $drvs | result/bin/nix-uncached)

          if [[ -n ''${uncached[*]} ]]; then
            mapfile -t uncached < <(nix show-derivation $drvs | jq -r '.| to_entries[] | select(.value|.env.preferLocalBuild != "1") | .key')
          fi

          if [[ -n ''${uncached[*]} ]]; then
            local list filtered

            list=$(jq -ncR '[inputs]' <<< "''${uncached[@]}")
            filtered=$(jq -c 'select([.targetDrv] | inside($p))' --argjson p "$list" <<< "''${input[@]}")

            output=$(jq -cs '. += $p' --argjson p "$output" <<< "$filtered")
          fi
        }
      '';
  }
