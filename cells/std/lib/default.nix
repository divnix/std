{
  inputs,
  cell,
}: let
  inherit (inputs) dmerge devshell nixago;
  nixpkgs = inputs.nixpkgs;

  l = nixpkgs.lib // builtins;
in {
  mkShell = import ./mkShell.nix {inherit inputs cell;};
  mkNixago = import ./mkNixago.nix {inherit inputs cell;};

  fromMakesWith = inputs': let
    inputsChecked = assert l.assertMsg (builtins.hasAttr "makes" inputs') (
      l.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'makes' must be defined in the flake. See inputs above.
      ''
    );
    assert l.assertMsg (builtins.hasAttr "nixpkgs" inputs') (
      l.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMakesWith', an input
        named 'nixpkgs' must be defined in the flake. See inputs above.
      ''
    ); inputs';
  in
    import ./fromMakesWith.nix {
      inputs = inputsChecked;
    };

  fromMicrovmWith = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "microvm" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMicrovmWith', an input
        named 'microvm' must be defined in the flake. See inputs above.

        microvm.url = "github:astro/microvm.nix";
      ''
    );
    assert nixpkgs.lib.assertMsg (builtins.hasAttr "nixpkgs" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.fromMicrovmWith', an input
        named 'nixpkgs' must be defined in the flake. See inputs above.
      ''
    ); inputs';
  in
    import ./fromMicrovmWith.nix {
      inputs = inputsChecked;
    };

  writeShellEntrypoint = inputs': let
    inputsChecked = assert nixpkgs.lib.assertMsg (builtins.hasAttr "n2c" inputs') (
      nixpkgs.lib.traceSeqN 1 inputs' ''

        In order to be able to use 'std.std.lib.writeShellEntrypoint', an input
        named 'n2c' (representing 'nlewo/nix2container') must be defined in the flake.
        See inputs above.
      ''
    ); inputs';
  in
    import ./writeShellEntrypoint.nix {
      inputs = inputsChecked;
      inherit cell;
    };
}
