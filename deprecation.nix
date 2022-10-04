inputs: let
  removeBy = import ./cells/std/errors/removeBy.nix {inherit inputs;};
in {
  warnClade = variant:
    removeBy "October 2022" ''

      "clade" nomenclature is deprecated.

      Please rename:

      - sed -i 's/clades/blockTypes/g'
      - sed -i 's/clade/blockType/g'
      - sed -i 's/Clades/Block Types/g'
      - sed -i 's/Clade/Block Type/g'

      There is an old revision of `std` in the evaluation path,
      possibly in one of your flake inputs.

      Detected in: ${variant}

      Please review your code base and/or inform upstream to
      update their version of Standard ASAP.

      see: https://github.com/divnix/std/issues/116
    '';

  warnOrganelles = project:
    removeBy "October 2022" ''

      "organelle" nomenclature is deprecated.

      Please rename:

      - sed -i 's/organelles/cellBlocks/g'
      - sed -i 's/organelle/cellBlock/g'
      - sed -i 's/Organelles/Cell Blocks/g'
      - sed -i 's/Organelle/Cell Block/g'

      There is an old revision of `std` in the evaluation path
      in project: ${toString project}

      Please review your code base and/or inform upstream to
      update their version of Standard ASAP.

      see: https://github.com/divnix/std/issues/116
    '';

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
}
