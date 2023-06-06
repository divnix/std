{
  inputs,
  scope,
}:
inputs.cells.lib.dev.mkNixago {
  data = {};
  output = "treefmt.toml";
  format = "toml";
  commands = [{package = inputs.nixpkgs.treefmt;}];
}
