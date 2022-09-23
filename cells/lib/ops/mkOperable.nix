{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in
  /*
  Makes a package operable by configuring the necessary runtime environment.

  Args:
  package: The package to wrap.
  runtimeScript: A bash script to run at runtime.
  runtimeEnv: An attribute set of environment variables to set at runtime.
  runtimeInputs: A list of packages to add to the runtime environment.
  livenessProbe: An optional derivation to run to check if the program is alive.
  readinessProbe: An optional derivation to run to check if the program is ready.

  Returns:
  An operable for the given package.
  */
  {
    package,
    runtimeScript,
    runtimeEnv ? {},
    runtimeInputs ? [],
    runtimeShell ? null,
    debugInputs ? [],
    livenessProbe ? null,
    readinessProbe ? null,
  }:
    (cell.lib.writeScript
      ({
          inherit runtimeInputs runtimeEnv;
          name = "operable-${package.name}";
          text = ''
            ${l.getExe nixpkgs.snore} "''${DEBUG_SLEEP:-0}"
            ${runtimeScript}
          '';
        }
        // l.optionalAttrs (runtimeShell != null) {
          inherit runtimeShell;
        }))
    // {
      # The livenessProbe and readinessProbe are picked up in later stages
      passthru =
        {
          inherit package runtimeInputs debugInputs;
        }
        // l.optionalAttrs (livenessProbe != null) {
          inherit livenessProbe;
        }
        // l.optionalAttrs (readinessProbe != null) {
          inherit readinessProbe;
        };
    }
