{
  inputs = {
    # injected inputs to override std's defaults
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "std/nixpkgs";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "std/nixpkgs";
    nixago.inputs.nixago-exts.follows = "";
    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "std/nixpkgs";
    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "std/nixpkgs";
    terranix.inputs.terranix-examples.follows = "";
    terranix.inputs.bats-support.follows = "";
    terranix.inputs.bats-assert.follows = "";
    namaka.url = "github:nix-community/namaka/v0.2.0";
    namaka.inputs.haumea.follows = "std/haumea";
    namaka.inputs.nixpkgs.follows = "std/nixpkgs";
    makes.url = "github:fluidattacks/makes";
    makes.inputs.nixpkgs.follows = "std/nixpkgs";
    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "std/nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "std/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # The only purpose of this is to construe the correct follows spec in flake.lock.
    # `std` will be fully shadowed below
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
