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
    runtimeShell ? nixpkgs.runtimeShell,
    debugInputs ? [],
    livenessProbe ? null,
    readinessProbe ? null,
  }: let
    # nixpkgs.runtimeShell is a path to the shell, not a derivation
    runtimeShellBin =
      if runtimeShell != nixpkgs.runtimeShell
      then (l.getExe runtimeShell)
      else nixpkgs.runtimeShell;

    # Create runtime environment
    runtime = cell.lib.writeScript {
      inherit runtimeEnv runtimeInputs runtimeShell;
      name = "runtime";
      text = ''
        exec ${runtimeShellBin}
      '';
    };

    # Configure debug environment
    banner = nixpkgs.runCommandNoCC "debug-banner" {} ''
      ${nixpkgs.figlet}/bin/figlet -f banner "STD Debug" > $out
    '';
    debug = cell.lib.writeScript {
      inherit runtimeEnv runtimeShell;
      name = "debug";
      runtimeInputs =
        [nixpkgs.coreutils]
        ++ debugInputs
        ++ runtimeInputs;
      text = ''
        cat ${banner}
        echo
        echo "=========================================================="
        echo "This debug shell contains the runtime environment and all"
        echo "debug dependencies."
        echo "=========================================================="
        echo
        exec ${runtimeShellBin}
      '';
    };
  in
    (cell.lib.writeScript
      ({
          inherit runtimeInputs runtimeEnv;
          name = "operable-${package.name}";
          text = ''
            ${runtimeScript}
          '';
        }
        // l.optionalAttrs (runtimeShell != null) {
          inherit runtimeShell;
        }))
    // {
      passthru =
        # These attributes are useful for informing later stages
        {
          inherit debug debugInputs package runtime runtimeInputs runtimeShell;
        }
        # The livenessProbe and readinessProbe are picked up in later stages
        // l.optionalAttrs (livenessProbe != null) {
          inherit livenessProbe;
        }
        // l.optionalAttrs (readinessProbe != null) {
          inherit readinessProbe;
        };
    }
