{
  cellPath = cellsFrom: cellName: {
    __toString = _: "${cellsFrom}/${cellName}";
    readme = "${cellsFrom}/${cellName}/Readme.md";
  };
  cellBlockPath = cellPath: cellBlock: {
    __toString = _: "${cellPath}/${cellBlock.name}";
    file = "${cellPath}/${cellBlock.name}.nix";
    dir = "${cellPath}/${cellBlock.name}/default.nix";
    readme = "${cellPath}/${cellBlock.name}/Readme.md";
  };
  targetPath = cellBlockPath: name: {
    readme = "${cellBlockPath}/${name}.md";
  };
}
