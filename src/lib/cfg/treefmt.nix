let
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = "treefmt.toml";
  format = "toml";
  commands = [{package = nixpkgs.treefmt;}];
}
