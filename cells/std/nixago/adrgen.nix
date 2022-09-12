{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  configData = {};
  output = "adrgen.config.yml";
  format = "yaml";
  commands = [{package = cell.packages.adrgen;}];
}
