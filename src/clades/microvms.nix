{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Microvms Clade for Microvm.nix - https://github.com/astro/microvm.nix
  Available actions:
    - run
  */
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
          nix run ${flake}#${fragment}.config.microvm.runner.qemu
        '';
      }
      {
        name = "kvmtool";
        description = "exec this microvm with kvmtool";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.kvmtool
        '';
      }
      {
        name = "firecracker";
        description = "exec this microvm with firecracker";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.firecracker
        '';
      }
      {
        name = "crosvm";
        description = "exec this microvm with crosvm";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.crosvm
        '';
      }
      {
        name = "cloud-hypervisor";
        description = "exec this microvm with cloud-hypervisor";
        command = ''
          nix run ${flake}#${fragment}.config.microvm.runner.cloud-hypervisor
        '';
      }
    ];
  };
in
  microvms
