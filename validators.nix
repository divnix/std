# SPDX-FileCopyrightText: 2022 David Arnold <dgx.arnold@gmail.com>
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{ inputs
, organelleName
, organellePaths
}:
let
  organellePathsList =
    cellsFrom: cell: organelle: inputs.nixpkgs.lib.reverseList (builtins.attrValues (organellePaths cellsFrom cell organelle));
  prefixWithCellsFrom =
    path:
    builtins.concatStringsSep
      "/"
      ([ "\${cellsFrom}" ] ++ (inputs.nixpkgs.lib.lists.drop 4 (inputs.nixpkgs.lib.splitString "/" path)));
in
{
  System =
    systemPair:
    let
      allKeysValid = builtins.all (k: builtins.elem k [ "build" "host" ]) (builtins.attrNames systemPair);
      allKeysPresent = builtins.all (k: builtins.elem k (builtins.attrNames systemPair)) [ "build" "host" ];
      buildValueIsValid = builtins.hasAttr systemPair.build inputs.self.systems;
      hostValueIsValid = builtins.hasAttr systemPair.host inputs.self.systems;
    in
      if !allKeysValid
      then
        abort
          ''


            The following system has invalid key(s):
            Keys: '${builtins.attrNames systemPair}'

            Valid keys are: 'build' & 'host'
          ''
      else if !allKeysPresent
      then
        abort
          ''


            The following system lacks a key:
            Keys: '${builtins.attrNames systemPair}'

            Required keys are: 'build' & 'host'
          ''
      else if !buildValueIsValid
      then
        abort
          ''


            System build value '${systemPair.build}' is not valid.
            Please pick one from the following:

            ${builtins.concatStringsSep "\n" (builtins.attrNames inputs.self.systems)}

          ''
      else if !hostValueIsValid
      then
        abort
          ''


            System build value '${systemPair.host}' is not valid.
            Please pick one from the following:

            ${builtins.concatStringsSep "\n" (builtins.attrNames inputs.self.systems)}

          ''
      else
        {
          build = inputs.self.systems.${ systemPair.build };
          host = inputs.self.systems.${ systemPair.host };
        };
  Cell =
    cellsFrom: organelles: cell: type:
    let
      atLeastOneOrganelle =
        builtins.any
          builtins.pathExists
          (inputs.nixpkgs.lib.lists.flatten (builtins.map (organellePathsList cellsFrom cell) organelles));
      badOrganelles =
        builtins.filter
          (
            organelle:
            builtins.length (organellePathsList cellsFrom cell organelle)
            > 1
            && builtins.all builtins.pathExists (organellePathsList cellsFrom cell organelle)
          );
    in
      if type != "directory"
      then
        abort
          ''


            Everything under ''${cellsFrom}/* is considered a Cell

            Cells are directories by convention and therefore
            only directories are allowed at ''${cellsFrom}/*

            Please remove ${"'"}''${cellsFrom}/${cell}' and don't forget to add the change to version control.

          ''
      else if !atLeastOneOrganelle
      then
        abort
          ''


            For Cell '${cell}' to be useful
            it needs to provide at least one Organelle

            In this project, the Organelles of a Cell can be
            ${builtins.concatStringsSep ", " (builtins.map organelleName organelles)}


            ${
            builtins.concatStringsSep
              "\n\n"
              (
                builtins.map
                  (
                    organelle:
                    let
                      numerator =
                        if (organelle ? o && organelle ? m)
                        then "one or more outputs"
                        else if (organelle ? o)
                        then "the single output"
                        else "outputs";
                      title = "To generate ${numerator} for Organelle '${organelleName organelle}', please create:\n";
                      list = "${
                        builtins.concatStringsSep
                          " or\n"
                          (
                            builtins.map
                              (p: "  - ${prefixWithCellsFrom p}")
                              (organellePathsList cellsFrom cell organelle)
                          )
                      }";
                    in
                      title + list
                  )
                  organelles
              )
          }

            Please create at least one of the previous files and don't forget to add them to version control.
          ''
      else if builtins.length (badOrganelles organelles) != 0
      then
        abort
          ''


            Cell Organelles can inject eiter a singleton output or an attribute set of outputs into the project flake, not both.
            Hence, please use only one of the following files:

            ${
            builtins.concatStringsSep
              "\n\n"
              (
                builtins.map
                  (
                    organelle:
                    (
                      builtins.concatStringsSep
                        " or\n"
                        (
                          builtins.map
                            (p: "  - ${prefixWithCellsFrom p}")
                            (organellePathsList cellsFrom cell organelle)
                        )
                    )
                  )
                  (badOrganelles organelles)
              )
          }

            Please remove either one and don't forget to add the changes to version control.

          ''
      else cell;
  Organelle =
    organelle:
    if !(organelle ? o || organelle ? m)
    then
      abort
        ''


          An Organelle must either have a "one" or "many" name or both.
          Please define in your organelles:
            - either { o = "one-name"; }
            - or { m = "many-name"; }
            - or both

        ''
    else if !(builtins.elem organelle.clade [ "runnables" "installables" "functions" ])
    then
      abort
        ''


          An Organelle must be of one of the following clades:
            - runnables
            - installables
            - functions

          Please define in your organelle ${organelleName organelle}:
          { clade = "<clade>"; }

        ''
    else organelle;
  OnePathImport =
    organelle: cellsFrom: cell: imported:
    let
      onePath = (organellePaths cellsFrom cell organelle).onePath or null;
      manyPath = (organellePaths cellsFrom cell organelle).manyPath or null;
    in
      if builtins.isAttrs imported && !inputs.nixpkgs.lib.isDerivation imported
      then
        abort
          ''


            The following file does contain an attribute set:
              - ${prefixWithCellsFrom onePath}

            ${
            if manyPath != null
            then
              "If you need several outputs, rename to:\n  - ${prefixWithCellsFrom manyPath}\n\nOtherwise, it must contain only a single output."
            else "But it must contain only a single output."
          }
          ''
      else if organelle.clade == "functions" && !builtins.isFunction imported
      then
        abort
          ''


            The following file of Clade 'functions' doesn't contain a function:
              - ${prefixWithCellsFrom onePath}

            But single output organelles of Clade 'function' must resolve to a single function.
          ''
      else imported;
  ManyPathImport =
    organelle: cellsFrom: cell: imported:
    let
      onePath = (organellePaths cellsFrom cell organelle).onePath or null;
      manyPath = (organellePaths cellsFrom cell organelle).manyPath or null;
    in
      if !builtins.isAttrs imported || inputs.nixpkgs.lib.isDerivation imported
      then
        abort
          ''


            The following file doesn't contain an attribute set:
              - ${prefixWithCellsFrom manyPath}

            ${
            if onePath != null
            then
              "If you only need one single output, consider renaming to:\n  - ${prefixWithCellsFrom onePath}\n\nOtherwise, it must contain an attribute set of outputs."
            else "But it must contain an attribute set of outputs."
          }
          ''
      else imported;
}
