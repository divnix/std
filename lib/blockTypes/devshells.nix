{
  nixpkgs,
  root,
  super,
}:
/*
Use the Devshells Blocktype for devShells.

Available actions:
  - build
  - enter
*/
let
  inherit (root) mkCommand actions devshellDrv;
  inherit (super) addSelectorFunctor;
  inherit (builtins) unsafeDiscardStringContext;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "devshells";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      developDrv = devshellDrv target;
    in [
      (actions.build currentSystem target)
      (mkCommand currentSystem "enter" "enter this devshell" ''
        profile_path="$PRJ_DATA_HOME/${fragmentRelPath}"
        mkdir -p "$profile_path"
        # ${developDrv}
        nix_args=(
          "${unsafeDiscardStringContext developDrv.drvPath}"
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
      '' {})
    ];
  }
