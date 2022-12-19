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
      flake,
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
          std_layout_dir=$PRJ_ROOT/.std
          profile_path="$std_layout_dir/${fragmentRelPath}"
          mkdir -p "$profile_path"
          # ${developDrv}
          nix_args=(
            "${builtins.builtins.unsafeDiscardStringContext developDrv.drvPath}"
            "--no-update-lock-file"
            "--no-write-lock-file"
            "--no-warn-dirty"
            "--accept-flake-config"
            "--no-link"
            "--build-poll-interval" "0"
            "--builders-use-substitutes"
          )
          nix build "''${nix_args[@]}" --profile "$profile_path/shell-profile"
          eval "$(nix print-dev-env ${developDrv})"
          if declare -F __devshell-motd &>/dev/null; then
            __devshell-motd
          fi
          if ! [[ -v STD_DIRENV ]]; then
            exec $SHELL -i
          fi
        '';
      }
    ];
  };
in
  devshells
