{
  nixpkgs,
  root,
  super,
}: let
  inherit (root) mkCommand;
  inherit (super) addSelectorFunctor;
in
  name: {
    __functor = addSelectorFunctor;
    inherit name;
    type = "namaka";
    actions = {
      currentSystem,
      fragment,
      fragmentRelPath,
      target,
    }: let
      inherit (nixpkgs.${currentSystem}) pkgs;
    in [
      (mkCommand currentSystem "check" "run namaka tests against snapshots" [pkgs.namaka] ''
        namaka check -c nix eval .#${fragment}
      '' {})
    ];
  }
