let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in
  {
    name,
    text,
    runtimeInputs ? [],
    runtimeEnv ? {},
    runtimeShell ? nixpkgs.runtimeShell,
    checkPhase ? null,
  }: let
    runtimeShell' =
      if runtimeShell != nixpkgs.runtimeShell
      then (l.getExe runtimeShell)
      else runtimeShell;
  in
    cell.ops.lazyDerivation {
      meta.mainProgram = name;
      derivation = nixpkgs.writeTextFile {
        inherit name;
        executable = true;
        destination = "/bin/${name}";
        text =
          ''
            #!${runtimeShell'}
            # shellcheck shell=bash
            set -o errexit
            set -o pipefail
            set -o nounset
            set -o functrace
            set -o errtrace
            set -o monitor
            set -o posix
            shopt -s dotglob

          ''
          + l.optionalString (runtimeInputs != []) ''
            export PATH="${l.makeBinPath runtimeInputs}:$PATH"
          ''
          + l.optionalString (runtimeEnv != {}) ''
            ${l.concatStringsSep "\n" (l.mapAttrsToList (n: v: "export ${n}=${''"$''}{${n}:-${toString v}}${''"''}") runtimeEnv)}
          ''
          + ''

            ${text}
          '';

        checkPhase =
          if checkPhase == null
          then ''
            runHook preCheck
            ${nixpkgs.stdenv.shellDryRun} "$target"
            ${nixpkgs.shellcheck}/bin/shellcheck "$target"
            runHook postCheck
          ''
          else checkPhase;
      };
    }
