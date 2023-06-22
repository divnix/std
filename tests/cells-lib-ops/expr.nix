{
  std,
  nixpkgs,
}: let
  # augmented std from the local cell
  inherit (std.lib) ops dev;
in
  builtins.mapAttrs (
    n: f:
      rec {
        mkMicrovm = let
          target = f {microvm.hypervisor = "qemu";};
        in
          target.config.microvm.runner.${target.config.microvm.hypervisor};
        mkOperable = f {
          package = nixpkgs.hello;
          runtimeScript = "exec ${nixpkgs.hello}/bin/hello";
        };
        mkStandardOCI = f {
          name = "docker.io/hello";
          operable = ops.mkOperable {
            package = nixpkgs.hello;
            runtimeScript = "exec ${nixpkgs.hello}/bin/hello";
          };
        };
        mkDevOCI = f {
          name = "docker.io/hello-dev";
          devshell = dev.mkShell {name = "Test";};
        };
      }
      .${n}
      or "missing-test"
  )
  ops
