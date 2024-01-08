let
  inherit (inputs.cells.std.errors) requireInput;

  inherit (requireInput "devshell" "github:numtide/devshell" "std.lib.dev.mkShell") devshell nixago;

  l = inputs.nixpkgs.lib // builtins;

  pkgs = import inputs.nixpkgs {
    inherit (inputs.nixpkgs) system;
    overlays = [devshell.overlays.default];
  };
in
  configuration: let
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
    pkgs.devshell.mkShell {
      imports = [configuration nixagoModule];
    }
