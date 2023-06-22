{std}: let
  # augmented std from the local cell
  inherit (std.lib) dev cfg;
in
  builtins.mapAttrs (
    n: f:
      {
        mkShell = f {name = "Test";};
        mkNixago = (f cfg.conform).configFile;
        mkMakes = f ./__mkMakes.nix {};
        mkArion =
          (f {
            project.name = "Test";
            services.postgres.service = {};
          })
          .config
          .out
          .dockerComposeYaml;
      }
      .${n}
      or "missing-test"
  )
  dev
