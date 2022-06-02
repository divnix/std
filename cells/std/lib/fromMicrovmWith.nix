{nixpkgs}: inputs': let
  inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "microvm" inputs') (
    nixpkgs.lib.traceSeqN 1 inputs' ''

      In order to be able to use 'std.std.lib.fromMicrovmWith', an input
      named 'microvm' must be defined in the flake. See inputs above.

      microm.url = "github:astro/microvm.nix";
    ''
  );
  assert nixpkgs.lib.assertMsg (builtins.hasAttr "nixpkgs" inputs') (
    nixpkgs.lib.traceSeqN 1 inputs' ''

      In order to be able to use 'std.std.lib.fromMicrovmWith', an input
      named 'nixpkgs' must be defined in the flake. See inputs above.
    ''
  ); inputs';
  microvm = channel: module: let
    nixosSystem = args:
      import "${channel.path}/nixos/lib/eval-config.nix" (args
        // {
          modules = args.modules;
        });
  in
    nixosSystem {
      inherit (inputsChecked.nixpkgs) system;
      modules = [
        # for declarative MicroVM management
        inputsChecked.microvm.nixosModules.host
        # this runs as a MicroVM that nests MicroVMs
        inputsChecked.microvm.nixosModules.microvm
        # your custom moduel
        module
      ];
    };
in
  microvm
