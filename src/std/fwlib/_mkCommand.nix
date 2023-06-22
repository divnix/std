{nixpkgs}: currentSystem: name: description: deps: command: args: let
  inherit (nixpkgs.${currentSystem}) pkgs;
  inherit (pkgs) lib stdenv haskell shellcheck runtimeShell;
  inherit (pkgs.haskell.lib.compose) justStaticExecutables;
in
  args
  // {
    inherit name description;
    command = pkgs.writeTextFile {
      inherit name;
      executable = true;
      checkPhase = ''
        runHook preCheck
        ${stdenv.shellDryRun} "$target"
        # use shellcheck which does not include docs
        # pandoc takes long to build and documentation isn't needed for in nixpkgs usage
        ${lib.getExe (justStaticExecutables shellcheck.unwrapped)} "$target"
        runHook postCheck
      '';
      text =
        ''
          #!${runtimeShell}
          set -o errexit
          set -o nounset
          set -o pipefail

          if test -z "$PRJ_ROOT"; then
            echo "All Standard Block Type Actions require an environment that fulfills the PRJ Base Directiory Specification"
            echo "see: https://github.com/numtide/prj-spec"
            echo "Tip: To achieve that, you can enter a Standard direnv environment or run the action via the Standard CLI/TUI"
            exit 1
          fi

          # Action Code follows ...
        ''
        + lib.optionalString (deps != []) ''
          # Be optionally reproducible due to potential overhead to load some
          # quaasi-ubiquitous dependencies that are already generally available
          export PATH="${lib.makeBinPath deps}:$PATH"
        ''
        + command;
    };
  }
