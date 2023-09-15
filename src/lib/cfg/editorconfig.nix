let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs;
in {
  data = {};
  output = ".editorconfig";
  engine = request: let
    inherit (request) data output;
    name = l.baseNameOf output;
    value = {
      globalSection = {root = data.root or true;};
      sections = l.removeAttrs data ["root"];
    };
  in
    nixpkgs.writeText name (l.generators.toINIWithGlobalSection {} value);
  packages = [nixpkgs.editorconfig-checker];
}
