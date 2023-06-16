{root}:
/*
Use the Microvms Blocktype for Microvm.nix - https://github.com/astro/microvm.nix

Available actions:
  - run
  - console
  - microvm
*/
let
  inherit (root) mkCommand;
in
  name: {
    inherit name;
    type = "microvms";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: [
      (mkCommand currentSystem "run" "run the microvm" ''
        ${target.config.microvm.runner.${target.config.microvm.hypervisor}}/bin/microvm-run
      '' {})
      (mkCommand currentSystem "console" "enter the microvm console" ''
        ${target.config.microvm.runner.${target.config.microvm.hypervisor}}/bin/microvm-console
      '' {})
      (mkCommand currentSystem "microvm" "pass any command to microvm" ''
        ${target.config.microvm.runner.${target.config.microvm.hypervisor}}/bin/microvm-"$@"
      '' {})
    ];
  }
