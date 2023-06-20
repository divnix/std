{nixpkgs}: currentSystem: name: description: command: args: let
  inherit (nixpkgs.legacyPackages.${currentSystem}) pkgs;
in
  args
  // {
    inherit name description;
    command =
      pkgs.writeShellScript "${name}" (''
        set -e

        if test -z "$PRJ_ROOT"; then
          echo "All Standard Block Type Actions require an environment that fulfills the PRJ Base Directiory Specification"
          echo "see: https://github.com/numtide/prj-spec"
          echo "Tip: To achieve that, you can enter a Standard direnv environment or run the action via the Standard CLI/TUI"
          exit 1
        fi

        # Action Code follows ...
      ''
      + command);
  }
