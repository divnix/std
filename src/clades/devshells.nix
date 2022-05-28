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
          std_layout_fragment_path=$std_layout_dir/${fragmentRelPath}
          mkdir -p $std_layout_fragment_path
          nix develop \
            ${flake}#${fragment} \
            --no-update-lock-file \
            --no-write-lock-file \
            --no-warn-dirty \
            --accept-flake-config \
            --profile "$std_layout_fragment_path/profile" \
            --command "$SHELL"
        '';
      }
    ];
  };
in
  devshells
