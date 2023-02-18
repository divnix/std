{
  inputs,
  cell,
}: let
  inherit (inputs) devshell nixago;

  l = inputs.nixpkgs.lib // builtins;
in
  configuration: let
    devenvModule = {
      config,
      lib,
      ...
    }:
      with lib; let
        cfg = config;
      in {
        options.devenv = mkOption {
          type = types.anything;
          default = null;
          description = "Devenv configuration";
        };
        config = mkIf (cfg.devenv != null) {
          env = [
            {
              name = "PRJ_STATE_DIR";
              eval = "$PRJ_ROOT/.std/state";
            }
            {
              name = "DEVENV_STATE";
              eval = "$PRJ_ROOT/.std/state";
            }
          ];
          commands = [
            {
              package = let
                mkDevenvDevShellPackage = config:
                  import (inputs.devenv + /src/devenv-devShell.nix) {
                    inherit config;
                    pkgs = inputs.nixpkgs;
                  };
              in
                mkDevenvDevShellPackage cfg.devenv;
              help = "Spin up development services";
            }
          ];
        };
      };

    nixagoModule = {
      config,
      lib,
      ...
    }:
      with lib; let
        cfg = config;
      in {
        options.nixago = mkOption {
          type = types.listOf types.attrs;
          default = [];
          apply = x: l.catAttrs "__passthru" x;
          description = "List of `std` Nixago pebbles to load";
        };

        config = let
          # effectuate side effects on treefmt nixago, if present
          # to prevent treefmt from formatting auto-generated files
          partitioned = l.partition (n: n.output == "treefmt.toml") cfg.nixago;
          treefmt' =
            l.map (
              t:
                l.recursiveUpdate t
                {
                  data.global.excludes =
                    t.data.global.excludes
                    or []
                    ++ (l.map (o: o.output) cfg.nixago);
                }
            )
            # if there's more than one treefmt, that's a malconfiguration
            # but here: we don't deal with that case
            partitioned.right;
          updated = treefmt' ++ partitioned.wrong;
        in
          mkIf (cfg.nixago != []) {
            devshell = let
              acc = l.foldl l.recursiveUpdate {};
            in
              acc (
                []
                ++ (l.map (o: o.devshell) updated)
                ++ [{startup.nixago-setup-hook = l.stringsWithDeps.noDepEntry (nixago.lib.makeAll updated).shellHook;}]
              );
            packages = l.concatMap (o: o.packages) updated;
            commands = l.concatMap (o: o.commands) updated;
          };
      };
  in
    devshell.legacyPackages.mkShell {
      imports = [configuration nixagoModule devenvModule];
    }
