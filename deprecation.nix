nixpkgs: let
  l = nixpkgs.lib // builtins;

  during = month: body: let
    pad = l.concatStringsSep "" (l.genList (_: " ") (16 - (l.stringLength month)));
  in
    l.warn ''


      ===============================================
      !!!  🔥️  STANDARD DEPRECATION WARNING  🔥️   !!!
      -----------------------------------------------
      !!! Action required until scheduled removal !!!
      !!! Sheduled Removal: ${pad}${month} 2022 !!!
      -----------------------------------------------
      On schedule, deprecated facilities will be
      removed from Standard without further warning.
      -----------------------------------------------
      ${body}
      ===============================================

      ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳ ⏳



    '';
in {
  warnClade = variant:
    during "October" ''

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
    during "October" ''

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
}
