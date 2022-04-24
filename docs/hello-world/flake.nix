{
  inputs.std.url = "github:divnix/std";

  outputs = {std, ...} @ inputs:
    std.grow {
      inherit inputs;
      cellsFrom = ./cells;
    };
}
