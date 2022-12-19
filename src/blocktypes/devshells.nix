{nixpkgs}: let
  l = nixpkgs.lib // builtins;
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
    }: [
      (import ./actions/build.nix target)
      {
        name = "enter";
        description = "enter this devshell";
        # TODO: use target, which will require some additional work because of
        # https://github.com/NixOS/nix/issues/7468
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
            "--build-poll-interval" "0"
            "--builders-use-substitutes"
          )
          nix build "''${nix_args[@]}" --profile "$profile_path/shell-profile"
          bash -c "source $profile_path/shell-profile/env.bash; SHLVL=$SHLVL; __devshell-motd; exec $SHELL -i"
        '';
      }
    ];
  };
in
  devshells
