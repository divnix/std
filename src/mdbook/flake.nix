{
  inputs = {
    # injected (private) inputs
    mdbook-paisano-preprocessor.url = "github:paisano-nix/mdbook-paisano-preprocessor";
    mdbook-paisano-preprocessor.inputs.nixpkgs.follows = "nixpkgs";
    mdbook-paisano-preprocessor.inputs.nixago.follows = "";
    mdbook-paisano-preprocessor.inputs.devshell.follows = "";

    # injected inputs to override std's defaults
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };
  outputs = i: i;
}
