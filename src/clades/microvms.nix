{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Microvms Clade for Microvm.nix - https://github.com/astro/microvm.nix
  Available actions:
    - run
  */

  substituters = "--option extra-substituters https://microvm.cachix.org";
  keys = "--option extra-trusted-public-keys microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=";

  microvms = name: {
    inherit name;
    clade = "microvms";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
    }: [
      {
        name = "qemu";
        description = "exec this microvm with qemu";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.qemu ${substituters} ${keys}
        '';
      }
      {
        name = "kvmtool";
        description = "exec this microvm with kvmtool";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.kvmtool ${substituters} ${keys}
        '';
      }
      {
        name = "firecracker";
        description = "exec this microvm with firecracker";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.firecracker ${substituters} ${keys}
        '';
      }
      {
        name = "crosvm";
        description = "exec this microvm with crosvm";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.crosvm ${substituters} ${keys}
        '';
      }
      {
        name = "cloud-hypervisor";
        description = "exec this microvm with cloud-hypervisor";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.cloud-hypervisor ${substituters} ${keys}
        '';
      }
    ];
  };
in
  microvms
