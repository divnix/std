# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  inherit (import ./paths.nix) cellPath organellePath;
  prefixWithCellsFrom = path:
    l.concatStringsSep "/" (
      ["\${cellsFrom}"]
      ++ (l.lists.drop 4 (l.splitString "/" path))
    );
in {
  Systems = with yants "std" "grow" "attrs";
    list (enum "system" l.systems.doubles.all);
  Cell = cellsFrom: organelles: cell: type: let
    cPath = cellPath cellsFrom cell;
    path = o: organellePath cPath o;
    atLeastOneOrganelle = l.any (x: x) (
      l.map (
        o: l.pathExists (path o).file || l.pathExists (path o).dir
      )
      organelles
    );
  in
    if type != "directory"
    then
      abort ''


        Everything under ''${cellsFrom}/* is considered a Cell

        Cells are directories by convention and therefore
        only directories are allowed at ''${cellsFrom}/*

        Please remove ${"'"}''${cellsFrom}/${cell}' and don't forget to add the change to version control.
      ''
    else if !atLeastOneOrganelle
    then
      abort ''


        For Cell '${cell}' to be useful
        it needs to provide at least one Organelle

        In this project, the Organelles of a Cell can be
        ${l.concatStringsSep ", " (l.map (o: o.name) organelles)}


        ${
          l.concatStringsSep "\n\n" (
            l.map (
              organelle: let
                title = "To generate output for Organelle '${organelle.name}', please create:\n";
                paths = "  - ${prefixWithCellsFrom (path organelle).file}; or\n  - ${prefixWithCellsFrom (path organelle).dir}";
              in
                title + paths
            )
            organelles
          )
        }

        Please create at least one of the previous files and don't forget to add them to version control.
      ''
    else cell;
  Organelles = with yants "std" "grow" "attrs";
    list (
      struct "organelle" {
        name = string;
        clade = enum "clades" ["runnables" "installables" "functions" "data"];
        actions = option (functionWithArgs {
          system = false;
          flake = false;
          fragment = false;
        });
      }
    );
  FileSignature = file: let
    file' = prefixWithCellsFrom file;
  in
    with yants "std" "import" file';
      functionWithArgs {
        inputs = false;
        cell = false;
      };
  Import = clade: file: let
    file' = prefixWithCellsFrom file;
  in
    with yants "std" "import" clade file';
    # unfortunately eval during check can cause infinite recursions
    # if clade == "runnables" || clade == "installables"
    # then attrs drv
    # else if clade == "functions"
    # then attrs function
    # else throw "unreachable";
      attrs any;
}
