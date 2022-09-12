{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  configData = {};
  output = "treefmt.toml";
  format = "toml";
  commands = [{package = nixpkgs.treefmt;}];
}
