# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{ nixpkgs
, systems
, organellePath
}:
let
  availableSystems = systems;
  prefixWithCellsFrom =
    path:
    builtins.concatStringsSep
      "/"
      ([ "\${cellsFrom}" ] ++ (nixpkgs.lib.lists.drop 4 (nixpkgs.lib.splitString "/" path)));
in
{
  System =
    systemPair:
    let
      allKeysValid = builtins.all (k: builtins.elem k [ "build" "host" ]) (builtins.attrNames systemPair);
      allKeysPresent = builtins.all (k: builtins.elem k (builtins.attrNames systemPair)) [ "build" "host" ];
      buildValueIsValid = builtins.hasAttr systemPair.build availableSystems;
      hostValueIsValid = builtins.hasAttr systemPair.host availableSystems;
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

            ${builtins.concatStringsSep "\n" (builtins.attrNames availableSystems)}

          ''
      else if !hostValueIsValid
      then
        abort
          ''


            System build value '${systemPair.host}' is not valid.
            Please pick one from the following:

            ${builtins.concatStringsSep "\n" (builtins.attrNames availableSystems)}

          ''
      else
        {
          build = availableSystems.${systemPair.build};
          host = availableSystems.${systemPair.host};
        };
  Cell =
    cellsFrom: organelles: cell: type:
    let
      atLeastOneOrganelle =
        builtins.any builtins.pathExists (builtins.map (o: organellePath cellsFrom cell o) organelles);
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
            ${builtins.concatStringsSep ", " (builtins.map (o: o.name) organelles)}


            ${
            builtins.concatStringsSep
              "\n\n"
              (
                builtins.map
                  (
                    organelle:
                    let
                      title = "To generate output for Organelle '${organelle.name}', please create:\n";
                      path = "  - ${prefixWithCellsFrom (organellePath cellsFrom cell organelle)}";
                    in
                      title + path
                  )
                  organelles
              )
          }

            Please create at least one of the previous files and don't forget to add them to version control.
          ''
      else cell;
  Organelle =
    organelle:
    if !(organelle ? name)
    then
      abort
        ''


          An Organelle must either have a name.
          Please define your organelles with a name:
            - { name = "my-name"; clade = "<clade>"; }

        ''
    else if !(builtins.elem organelle.clade [ "runnables" "installables" "functions" ])
    then
      abort
        ''


          An Organelle must be of one of the following clades:
            - runnables
            - installables
            - functions

          Please define in your organelle ${organelle.name}:
          { name = "<name>"; clade = "<clade>"; }

        ''
    else organelle;
  ManyPathImport =
    organelle: cellsFrom: cell: imported:
    let
      path = organellePath cellsFrom cell organelle;
    in
      if !builtins.isAttrs imported || nixpkgs.lib.isDerivation imported
      then
        abort
          ''


            The following file doesn't contain an attribute set:
              - ${prefixWithCellsFrom path}

            But it must contain an attribute set of outputs.
          ''
      else imported;
}
