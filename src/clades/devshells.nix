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
            "${flake}#${fragment}"
            "--no-update-lock-file"
            "--no-write-lock-file"
            "--no-warn-dirty"
            "--accept-flake-config"
            "--keep-outputs"
          )
          nix build "''${nix_args[@]}" --profile "$profile_path/shell-profile"
          nix develop "''${nix_args[@]}" --profile "$profile_path/env-profile" --command "$SHELL"
        '';
      }
    ];
  };
in
  devshells
