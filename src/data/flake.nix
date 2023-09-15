{
  inputs = {
    # injected (private) inputs
    paisano-mdbook-preprocessor.url = "github:paisano-nix/mdbook-paisano-preprocessor";
    paisano-mdbook-preprocessor.inputs.nixpkgs.follows = "nixpkgs";
    paisano-mdbook-preprocessor.inputs.nixago.follows = "";
    paisano-mdbook-preprocessor.inputs.devshell.follows = "";

    # injected inputs to override std's defaults
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };
  outputs = i: i;
}
