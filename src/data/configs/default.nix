{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.mdbook-paisano-preprocessor.app.package) mdbook-paisano-preprocessor;
  inherit (inputs.cells.lib) cfg;

  inherit (inputs.nixpkgs.lib) recursiveUpdate;
in {
  adrgen = recursiveUpdate cfg.adrgen (import ./adrgen.nix);
  editorconfig = recursiveUpdate cfg.editorconfig (import ./editorconfig.nix);
  conform = recursiveUpdate cfg.conform (import ./conform.nix);
  lefthook = recursiveUpdate cfg.lefthook (import ./lefthook.nix);
  mdbook = recursiveUpdate cfg.mdbook (scopedImport {inherit inputs;} ./mdbook.nix);
  treefmt = recursiveUpdate cfg.treefmt (scopedImport {inherit inputs;} ./treefmt.nix);
  githubsettings = recursiveUpdate cfg.githubsettings (import ./githubsettings.nix);
  cog = recursiveUpdate cfg.cog (import ./cog.nix);
}
