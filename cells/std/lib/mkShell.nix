{
  inputs,
  cell,
}: let
  inherit (inputs) devshell nixago;

  l = inputs.nixpkgs.lib // builtins;
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

        config = mkIf (cfg.nixago != []) {
          devshell = let
            acc = l.foldl l.recursiveUpdate {};
          in
            acc (
              []
              ++ (l.map (o: o.devshell) cfg.nixago)
              ++ [{startup.nixago-setup-hook = l.stringsWithDeps.noDepEntry (nixago.lib.makeAll cfg.nixago).shellHook;}]
            );
          packages = l.concatMap (o: o.packages) cfg.nixago;
          commands = l.concatMap (o: o.commands) cfg.nixago;
        };
      };
  in
    devshell.legacyPackages.mkShell {
      imports = [configuration nixagoModule];
    }
