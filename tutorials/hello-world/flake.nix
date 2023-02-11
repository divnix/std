{
  inputs.std.url = "github:divnix/std";
  inputs.nixpkgs.url = "nixpkgs";

  outputs = {std, ...} @ inputs:
    std.grow {
      inherit inputs;
      cellsFrom = ./cells;
    };
}
