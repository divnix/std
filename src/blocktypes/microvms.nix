{nixpkgs}: let
  l = nixpkgs.lib // builtins;
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
      run = target':
      # this is the exact sequence mentioned by the `nix run` docs
      # and so should be compatible
        target'.program
        or "${target'}/bin/${target'.meta.mainProgram
          or (target'.pname
            or (l.removeSuffix "-${target.version or ""}" target.name))}";
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
