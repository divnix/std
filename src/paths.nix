{
  cellPath = cellsFrom: cellName: {
    __toString = _: "${cellsFrom}/${cellName}";
    readme = "${cellsFrom}/${cellName}/Readme.md";
  };
  organellePath = cellPath: organelle: {
    __toString = _: "${cellPath}/${organelle.name}";
    file = "${cellPath}/${organelle.name}.nix";
    dir = "${cellPath}/${organelle.name}/default.nix";
    readme = "${cellPath}/${organelle.name}/Readme.md";
  };
  targetPath = organellePath: name: {
    readme = "${organellePath}/${name}.md";
  };
}
