# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  inherit (import ./paths.nix) cellPath cellBlockPath;
  prefixWithCellsFrom = path:
    l.concatStringsSep "/" (
      ["\${cellsFrom}"]
      ++ (l.lists.drop 4 (l.splitString "/" path))
    );
in {
  Systems = with yants "std" "grow" "attrs";
    list (enum "system" l.systems.doubles.all);
  Cell = cellsFrom: cellBlocks: cell: type: let
    cPath = cellPath cellsFrom cell;
    path = o: cellBlockPath cPath o;
    atLeastOneCellBlock = l.any (x: x) (
      l.map (
        o: l.pathExists (path o).file || l.pathExists (path o).dir
      )
      cellBlocks
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
    else if !atLeastOneCellBlock
    then
      abort ''


        For Cell '${cell}' to be useful
        it needs to provide at least one Cell Block

        In this project, the Cell Blocks can be
        ${l.concatStringsSep ", " (l.map (o: o.name) cellBlocks)}


        ${
          l.concatStringsSep "\n\n" (
            l.map (
              cellBlock: let
                title = "To generate output for Cell Block '${cellBlock.name}', please create:\n";
                paths = "  - ${prefixWithCellsFrom (path cellBlock).file}; or\n  - ${prefixWithCellsFrom (path cellBlock).dir}";
              in
                title + paths
            )
            cellBlocks
          )
        }

        Please create at least one of the previous files and don't forget to add them to version control.
      ''
    else cell;
  CellBlocks = with yants "std" "grow" "attrs";
    list (
      struct "cellBlock" {
        name = string;
        clade = string;
        actions = option (functionWithArgs {
          system = false;
          flake = false;
          fragment = false;
          fragmentRelPath = false;
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
