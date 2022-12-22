{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  mkDevelopDrv = import ../devshell-drv.nix;
  /*
  Use the Devshells Blocktype for devShells.

  Available actions:
    - build
    - enter
  */
  devshells = name: {
    __functor = import ./__functor.nix;
    inherit name;
    type = "devshells";
    actions = {
      system,
      fragment,
      fragmentRelPath,
      target,
    }: let
      developDrv = mkDevelopDrv target;
    in [
      (import ./actions/build.nix developDrv)
      {
        name = "enter";
        description = "enter this devshell";
        command = ''
          if test -z "$PRJ_ROOT"; then
            echo "PRJ_ROOT is not set. Action aborting."
            exit 1
          fi
          if test -z "$PRJ_DATA_DIR"; then
            echo "PRJ_DATA_DIR is not set. Action aborting."
            exit 1
          fi
          profile_path="$PRJ_DATA_DIR/${fragmentRelPath}"
          mkdir -p "$profile_path"
          # ${developDrv}
          nix_args=(
            "${builtins.unsafeDiscardStringContext developDrv.drvPath}"
            "--no-update-lock-file"
            "--no-write-lock-file"
            "--no-warn-dirty"
            "--accept-flake-config"
            "--no-link"
            "--build-poll-interval" "0"
            "--builders-use-substitutes"
          )
          nix build "''${nix_args[@]}" --profile "$profile_path/shell-profile"
          _SHELL="$SHELL"
          eval "$(nix print-dev-env ${developDrv})"
          SHELL="$_SHELL"
          if ! [[ -v STD_DIRENV ]]; then
            if declare -F __devshell-motd &>/dev/null; then
              __devshell-motd
            fi
            exec $SHELL -i
          fi
        '';
      }
    ];
  };
in
  devshells
