out: mkCommand: let
  contextFreeDrv =
    builtins.unsafeDiscardStringContext out.drvPath;
  contextFreeOut =
    builtins.unsafeDiscardStringContext out;
in
  mkCommand {
    name = "build";
    description = "build this target";
    command = ''
      # ${out}
      nix build ${contextFreeDrv}
    '';
    proviso = ''
      nix build github:divnix/nix-uncached/v2.12.1

      cached="$(result/bin/nix-uncached "${contextFreeOut}")"

      if [[ -n $cached ]]; then
        cached="$(nix show-derivation "${contextFreeOut}" | jq -r '.| to_entries[] | select(.value|.env.preferLocalBuild != "1") | .key')"
      fi

      if [[ -z $cached ]]; then
        # skip the build in CI, since everything is already cached
        exit 1
      fi
    '';
  }
