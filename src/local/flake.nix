{
  inputs = {
    # injected (private) inputs
    namaka.url = "github:nix-community/namaka/v0.2.0";
    namaka.inputs.haumea.follows = "std/haumea";
    namaka.inputs.nixpkgs.follows = "nixpkgs";

    # injected inputs to override std's defaults
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    nixago.inputs.nixago-exts.follows = "";
    n2c.url = "github:nlewo/nix2container";
    n2c.inputs.nixpkgs.follows = "nixpkgs";

    # The only purpose of this is to construe the correct follows spec in flake.lock.
    # `std` will be fully shadowed below
    std = {
      url = "../../";
      inputs.devshell.follows = "devshell";
      inputs.nixago.follows = "nixago";
      inputs.n2c.follows = "n2c";
      # we might want to use newer nixpkgs for newer tools
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = i: i;
}
