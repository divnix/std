{nixpkgs}: let
  lib = nixpkgs.lib // builtins;
  /*
  Use the Microvms Blocktype for Microvm.nix - https://github.com/astro/microvm.nix

  Available actions:
    - microvm
  */

  microvms = name: {
    inherit name;
    type = "microvms";
    actions = {
      system,
      flake,
      fragment,
      fragmentRelPath,
      target,
    }: let
      run = import ./actions/run.nix {
        inherit target lib;
      };
    in [
      {
        name = "microvm";
        description = "exec this microvm";
        command = ''
          ${run target.config.microvm.runner.${target.config.microvm.hypervisor}}
        '';
      }
    ];
  };
in
  microvms
