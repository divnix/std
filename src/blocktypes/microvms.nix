{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Microvms Blocktype for Microvm.nix - https://github.com/astro/microvm.nix

  Available actions:
    - microvm
  */
  substituters = "--option extra-substituters https://microvm.cachix.org";
  keys = "--option extra-trusted-public-keys microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys=";

  microvms = name: {
    inherit name;
    type = "microvms";
    actions = {
      system,
      fragment,
      fragmentRelPath,
    }: let
      run = ["nix" "run" "$PRJ_ROOT#${fragment}.config.microvm.runner"];
    in [
      {
        name = "microvm";
        description = "exec this microvm";
        command =
          (l.concatStringsSep "\t" run)
          + ".$(nix eval --json --option warn-dirty false\ "
          + "$PRJ_ROOT#${fragment}.config.microvm.hypervisor)"
          + "\ ${substituters} ${keys}";
      }
    ];
  };
in
  microvms
