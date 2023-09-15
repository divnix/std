let
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = "cog.toml";
  commands = [
    {
      package = nixpkgs.cocogitto;
      name = "cog";
    }
  ];
}
