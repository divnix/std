inputs: let
  removeBy = import ./cells/std/errors/removeBy.nix {inherit inputs;};
in {
  warnRemovedDevshellOptionAdr = removeBy "December 2022" ''
    The std.adr.enable option has been removed from the std shell.
    Please look for something like "adr.enable = false" and drop it.
  '';
  warnRemovedDevshellOptionDocs = removeBy "December 2022" ''
    The std.docs.enable option has been removed from the std shell.
    Please look for something like "docs.enable = false" and drop it.
  '';
  warnMkMakes = removeBy "December 2022" ''
    std.lib.fromMakesWith has been refactored to std.lib.mkMakes.

    It furthermore doesn't take 'inputs' as its first argument
    anymore.
  '';
  warnMkMicrovm = removeBy "December 2022" ''
    std.lib.fromMicrovmWith has been refactored to std.lib.mkMicrovm.

    It furthermore doesn't take 'inputs' as its first argument
    anymore.
  '';

  warnNewLibCell = removeBy "December 2022" ''

    'std.std.lib' has been distributed into its own cell 'std.lib'

    Please access functions via their new location:

    ... moved to 'std.lib.ops':
    - 'std.std.lib.mkMicrovm' -> 'std.lib.ops.mkMicrovm'
    - 'std.std.lib.writeShellEntrypoint' -> 'std.lib.ops.writeShellEntrypoint'

    ... moved to 'std.lib.dev':
    - 'std.std.lib.mkShell' -> 'std.lib.dev.mkShell'
    - 'std.std.lib.mkNixago' -> 'std.lib.dev.mkNixago'
    - 'std.std.lib.mkMakes' -> 'std.lib.dev.mkMakes'
  '';

  warnWriteShellEntrypoint = removeBy "December 2022" ''

    'std.lib.ops.writeShellEntrypoint' is deprecated.

    Instead, use 'std.lib.ops.mkOperable' together
    with 'std.lib.ops.mkStandardOCI'.

    Please consult its documentation.
  '';

  warnOldActionInterface = actions:
    removeBy "March 2023" ''

      The action interface has chaged from:
        { system, flake, fragment, fragmentRelPath }
      To:
        { system, target, fragment, fragmentRelPath }

      Please adjust the following actions:

      ${builtins.concatStringsSep "\n" (map (a: " - ${a.name}: ${(builtins.unsafeGetAttrPos "name" a).file}") actions)}
    '';

  warnNixagoOutfactored = removeBy "May 2023" ''

    std.presets.nixago has been outfactored into its own repository.

    Add to your flake.nix

    inputs.std-data-collection.url = "github:divnix/std-data-collection";
    inputs.std-data-collection.inputs.std.follows = "std";
    inputs.std-data-collection.inputs.nixpkgs.follows = "nixpkgs";

    Replace accessors of
      `inputs.std.presets.nixago`
    with
      `inputs.std-data-collection.data.configs`
  '';
}
