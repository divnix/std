{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = "adrgen.config.yml";
  format = "yaml";
  commands = [{package = inputs.cells.std.packages.adrgen;}];
}
