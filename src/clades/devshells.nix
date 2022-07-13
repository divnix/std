{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Devshells Clade for devShells.

  Available actions:
    - enter
  */
  devshells = name: {
    inherit name;
    clade = "devshells";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "enter";
        description = "enter this devshell";
        command = ''
          std_layout_dir=$PRJ_ROOT/.std
          profile_path="$std_layout_dir/${fragmentRelPath}"
          mkdir -p "$profile_path"
          nix_args=(
            "$PRJ_ROOT#${fragment}"
            "--no-update-lock-file"
            "--no-write-lock-file"
            "--no-warn-dirty"
            "--accept-flake-config"
            "--no-link"
            "--keep-outputs"
            "--build-poll-interval" "0"
          )
          nix build "''${nix_args[@]}" --profile "$profile_path/shell-profile"
          bash -c "source $profile_path/shell-profile/env.bash; SHLVL=$SHLVL; __devshell-motd; exec $SHELL -i"
        '';
      }
    ];
  };
in
  devshells
