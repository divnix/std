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
    namaka.url = "github:nix-community/namaka/v0.2.0";
    namaka.inputs.haumea.follows = "std/haumea";
    namaka.inputs.nixpkgs.follows = "nixpkgs";
    makes.url = "github:fluidattacks/makes";
    makes.inputs.nixpkgs.follows = "nixpkgs";
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
    std = {
      url = "../../";
      inputs.devshell.follows = "devshell";
      inputs.nixago.follows = "nixago";
      inputs.n2c.follows = "n2c";
      inputs.makes.follows = "makes";
      inputs.arion.follows = "arion";
      inputs.microvm.follows = "microvm";
    };
  };
  outputs = i: i;
}
