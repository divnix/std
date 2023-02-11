{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = "adrgen.config.yml";
  format = "yaml";
  commands = [{package = cell.packages.adrgen;}];
}
