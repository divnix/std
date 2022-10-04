{inputs}: let
  inherit (inputs) nixpkgs microvm;
  nixosSystem = args:
    import "${nixpkgs.path}/nixos/lib/eval-config.nix" (args
      // {
        modules = args.modules;
      });
in
  module:
    nixosSystem {
      inherit (nixpkgs) system;
      modules = [
        # for declarative MicroVM management
        microvm.nixosModules.host
        # this runs as a MicroVM that nests MicroVMs
        microvm.nixosModules.microvm
        # your custom module
        module
      ];
    }
