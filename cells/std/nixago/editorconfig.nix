{
  inputs,
  cell,
}: let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
in {
  configData = {};
  output = ".editorconfig";
  engine = request: let
    inherit (request) configData output;
    name = l.baseNameOf output;
    value = {
      globalSection = {root = configData.root or true;};
      sections = l.removeAttrs configData ["root"];
    };
  in
    nixpkgs.writeText name (l.generators.toINIWithGlobalSection {} value);
  packages = [nixpkgs.editorconfig-checker];
}
