let
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = "adrgen.config.yml";
  format = "yaml";
  commands = [{package = nixpkgs.adrgen;}];
}
