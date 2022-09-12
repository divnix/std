{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  configData = {};
  output = ".editorconfig";
  format = "ini";
  packages = [nixpkgs.editorconfig-checker];
}
