{
  nixpkgs,
  mkCommand,
}: let
  lib = nixpkgs.lib // builtins;
  /*
  Use the Microvms Blocktype for Microvm.nix - https://github.com/astro/microvm.nix

  Available actions:
    - run
    - console
    - microvm
  */

  microvms = name: {
    inherit name;
    type = "microvms";
    actions = {
      system,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (mkCommand system {
        name = "run";
        description = "run the microvm";
        command = ''
          ${target.config.microvm.runner.${target.config.microvm.hypervisor}}/bin/microvm-run
        '';
      })
      (mkCommand system {
        name = "console";
        description = "enter the microvm console";
        command = ''
          ${target.config.microvm.runner.${target.config.microvm.hypervisor}}/bin/microvm-console
        '';
      })
      (mkCommand system {
        name = "microvm";
        description = "pass any command to microvm";
        command = ''
          ${target.config.microvm.runner.${target.config.microvm.hypervisor}}/bin/microvm-"$@"
        '';
      })
    ];
  };
in
  microvms
