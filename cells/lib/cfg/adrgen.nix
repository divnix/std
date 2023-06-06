{
  inputs,
  scope,
}:
inputs.cells.lib.dev.mkNixago {
  data = {};
  output = "adrgen.config.yml";
  format = "yaml";
  commands = [{package = inputs.cells.std.packages.adrgen;}];
}
