{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  Use the Microvms Clade for Microvm.nix - https://github.com/astro/microvm.nix

  Available actions:
    - microvm
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
    }: let
      run = ["nix" "run" "${flake}#${fragment}.config.microvm.runner"];
    in [
      {
        name = "microvm";
        description = "exec this microvm";
        command =
          (l.concatStringsSep "\t" run)
          + ".$(nix eval --json --option warn-dirty false\ "
          + "${flake}#${fragment}.config.microvm.hypervisor)"
          + "\ ${substituters} ${keys}";
      }
    ];
  };
in
  microvms
