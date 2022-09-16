{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
  n2c = inputs.n2c.packages.nix2container;

  stdImageDocs = "https://divnix.github.io/std/reference/std/lib/writeShellEntrypoint.html";
  locales = nixpkgs.glibcLocales.override {allLocales = false;};

  mkOCI = entrypoint: name: {
    inherit name;
    layers = [
      (n2c.buildLayer {
        deps = entrypoint.runtimeInputs;
        maxLayers = 10;
      })
      # dependencies
      (n2c.buildLayer {
        deps = [entrypoint.package];
        maxLayers = 90;
      })
    ];
    contents =
      [entrypoint.runtime]
      ++ (l.optional (entrypoint.livenessProbe != null) entrypoint.livenessProbe)
      ++ (l.optional (entrypoint.readinessProbe != null) entrypoint.readinessProbe);
    config.Cmd = ["${entrypoint}/bin/entrypoint"];
    config.User = "65534"; # nobody
    config.Group = "65534"; # nogroup
    config.Labels =
      (l.optionalAttrs (entrypoint.package ? src) {
        "org.opencontainers.image.source" = "file://${l.unsafeDiscardStringContext entrypoint.package.src}";
      })
      // (l.optionalAttrs (entrypoint.package.meta ? description) {
        "org.opencontainers.image.description" = entrypoint.package.meta.description;
      })
      // (l.optionalAttrs (entrypoint.package.meta ? license && entrypoint.package.meta.license ? spdxId) {
        "org.opencontainers.image.licenses" = entrypoint.package.meta.license.spdxId;
      })
      // {
        "org.opencontainers.image.url" = stdImageDocs;
        "org.opencontainers.image.version" = l.getVersion entrypoint.package;
        "org.opencontainers.image.title" = "Standard Image for ${l.getName entrypoint.package}";
      };
  };

  mkDebugOCI = entrypoint: name: let
    debug-banner = nixpkgs.runCommandNoCC "debug-banner" {} ''
      ${nixpkgs.figlet}/bin/figlet -f banner "STD Debug" > $out
    '';
    debug-tools = with nixpkgs.pkgsStatic; [busybox];
    debug-bin = nixpkgs.writeShellApplication {
      name = "debug";
      runtimeInputs =
        (entrypoint.runtimeInputs or [])
        ++ entrypoint.debugInputs or []
        ++ debug-tools;
      text = ''
        # shellcheck source=/dev/null
        # source ''${cacert}/nix-support/setup-hook

        cat ${debug-banner}
        echo
        echo "=========================================================="
        echo "This debug shell contains the runtime environment and "
        echo "debug dependencies of the entrypoint."
        echo "To inspect the entrypoint(s) run:"
        echo "cat ${entrypoint}/bin/*"
        echo "=========================================================="
        echo
        exec bash "$@"
      '';
    };
    oci = mkOCI entrypoint name;
  in
    oci
    // {
      layers =
        (oci.layers or [])
        ++ [
          # prepare a special layer that bundles all generic debugging packages
          (n2c.buildLayer {
            deps = debug-tools ++ [debug-banner];
            maxLayers = 1;
          })
          # prepare a special layer that bundles the relatively stable extra debugging packages
          (n2c.buildLayer {
            deps = entrypoint.debugInputs;
            maxLayers = 4;
          })
        ];
      contents = (oci.contents or []) ++ [debug-bin];
      config =
        oci.config
        // {
          Labels =
            oci.config.Labels
            // {
              "org.opencontainers.image.title" = "Debug Image for ${l.getName entrypoint.package}";
            };
        };
    };

  entrypoint = {
    # the installable that is wrapped by this entrypoint (re-exported)
    package,
    # the bash litteral string of the entrypoint
    entrypoint,
    # initialize environment variables with these defaults
    env ? {},
    # runtime installables that the entrypoint or liveness/readiness probe uses (re-exported)
    runtimeInputs ? [],
    # domain specific debugging utilities (re-exported)
    debugInputs ? [],
    # domain specific liveness probe (re-exported)
    livenessProbe ? null,
    # domain specific readiness probe (re-exported)
    readinessProbe ? null,
  }: let
    prelude = ''
      #!${nixpkgs.pkgsStatic.bash.out}/bin/bash
      set -o errexit
      set -o nounset
      set -o pipefail

      export PATH="${l.makeBinPath ([package] ++ runtimeInputs)}:$PATH"

      ${l.optionalString (nixpkgs.stdenv.hostPlatform.libc == "glibc") "export LOCALE_ARCHIVE=${locales}/lib/locale/locale-archive"}
      ${l.concatStringsSep "\n" (l.mapAttrsToList (n: v: "export ${n}=${''"$''}{${n}:-${toString v}}${''"''}") env)}
    '';
    checkPhase' = path: ''
      runHook preCheck
      ${nixpkgs.stdenv.shell} -n $out/${path}
      ${nixpkgs.shellcheck}/bin/shellcheck $out/${path}
      runHook postCheck
    '';
    live =
      if livenessProbe != null
      then
        nixpkgs.writeTextFile {
          name = "live";
          executable = true;
          destination = "/bin/live";
          checkPhase = checkPhase' "/bin/live";
          text = ''
            ${prelude}

            ${livenessProbe}
          '';
        }
      else null;
    ready =
      if readinessProbe != null
      then
        nixpkgs.writeTextFile {
          name = "ready";
          executable = true;
          destination = "/bin/ready";
          checkPhase = checkPhase' "/bin/ready";
          text = ''
            ${prelude}

            ${readinessProbe}
          '';
        }
      else null;
    runtime = nixpkgs.writeTextFile {
      name = "runtime";
      executable = true;
      destination = "/bin/runtime";
      checkPhase = checkPhase' "/bin/runtime";
      text = prelude;
    };
    inner =
      nixpkgs.writeTextFile {
        name = "entrypoint";
        executable = true;
        destination = "/bin/entrypoint";
        checkPhase = checkPhase' "/bin/entrypoint";
        text = ''
          ${prelude}

          sleep "''${DEBUG_SLEEP:-0}"
          ${entrypoint}
        '';
        meta = {
          mainProgram = "entrypoint";
          description = "Standard entrypoint for ${l.getName package}";
        };
      }
      // {
        # include runtimeShell as input data for image layer optimization
        runtimeInputs =
          runtimeInputs
          ++ [nixpkgs.pkgsStatic.bash.out]
          ++ (l.optional (nixpkgs.stdenv.hostPlatform.libc == "glibc") locales);
        livenessProbe = live;
        readinessProbe = ready;
        inherit debugInputs package live ready runtime;
      };
  in
    inner
    // {
      mkOCI = name: n2c.buildImage (mkOCI inner name);
      mkDebugOCI = name: n2c.buildImage (mkDebugOCI inner name);
      inherit
        (inner)
        package
        runtimeInputs
        debugInputs
        livenessProbe
        readinessProbe
        ;
    };
in
  entrypoint
