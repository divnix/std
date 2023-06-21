{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.nixago-exts.follows = "";
    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";
    std = {
      url = "../../";
      inputs.devshell.follows = "devshell";
      inputs.nixago.follows = "nixago";
      inputs.n2c.follows = "n2c";
    };
    paisano-mdbook-preprocessor.url = "github:paisano-nix/mdbook-paisano-preprocessor";
    paisano-mdbook-preprocessor.inputs.std.follows = "std";
    paisano-mdbook-preprocessor.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = i: i;
}
