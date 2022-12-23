{
  nixpkgs,
  mkCommand,
}: let
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
      fragment,
      fragmentRelPath,
      target,
    }: let
      run = import ./actions/run.nix {
        inherit target lib;
      };
    in [
      (mkCommand system "microvms" {
        name = "microvm";
        description = "exec this microvm";
        command = ''
          ${target.config.microvm.runner.${target.config.microvm.hypervisor}}
        '';
      })
    ];
  };
in
  microvms
