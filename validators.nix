# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{ nixpkgs
, yants
, systems
, organelleFilePath
}:
let
  availableSystems = systems;
  prefixWithCellsFrom = path: builtins.concatStringsSep "/" (
    [ "\${cellsFrom}" ]
    ++ (nixpkgs.lib.lists.drop 4 (nixpkgs.lib.splitString "/" path))
  );
in
{
  Systems =
    with yants "std" "grow" "attrs";
    list (
      struct "system" {
        build = restrict "available system" (s: builtins.hasAttr s availableSystems)
        string;
        host = restrict "available system" (s: builtins.hasAttr s availableSystems)
        string;
      }
    );
  Cell = cellsFrom: organelles: cell: type: let
    atLeastOneOrganelle = builtins.any builtins.pathExists (builtins.map (o: organelleFilePath cellsFrom cell o) organelles);
  in
    if type != "directory"
    then
      abort ''


                  Everything under ''${cellsFrom}/* is considered a Cell

                  Cells are directories by convention and therefore
                  only directories are allowed at ''${cellsFrom}/*

                  Please remove ${"'"}''${cellsFrom}/${cell}' and don't forget to add the change to version control.
        ca
      ''
    else if !atLeastOneOrganelle
    then
      abort ''


        For Cell '${cell}' to be useful
        it needs to provide at least one Organelle

        In this project, the Organelles of a Cell can be
        ${builtins.concatStringsSep ", " (builtins.map (o: o.name) organelles)}


        ${
        builtins.concatStringsSep "\n\n" (
          builtins.map (
            organelle: let
              title = "To generate output for Organelle '${organelle.name}', please create:\n";
              filePath = "  - ${
                prefixWithCellsFrom (organelleFilePath cellsFrom cell organelle)
              }";
            in
              title + filePath
          )
          organelles
        )
      }

        Please create at least one of the previous files and don't forget to add them to version control.
      ''
    else cell;
  Organelles =
    with yants "std" "grow" "attrs";
    list (
      struct "organelle" {
        name = string;
        clade = enum "clades" [ "runnables" "installables" "functions" ];
      }
    );
  ManyPathImport = organelle: cellsFrom: cell: imported: let
    filePath = organelleFilePath cellsFrom cell organelle;
  in
    if !builtins.isAttrs imported || nixpkgs.lib.isDerivation imported
    then
      abort ''


        The following file doesn't contain an attribute set:
          - ${prefixWithCellsFrom filePath}

        But it must contain an attribute set of outputs.
      ''
    else imported;
}
