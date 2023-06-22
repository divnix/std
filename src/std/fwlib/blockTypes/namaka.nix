{
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
      inputs,
    }: let
      pkg = inputs.namaka.packages.${currentSystem}.default;
    in [
      (mkCommand currentSystem "check" "run namaka tests against snapshots" [pkg] ''
        namaka check -c nix eval '.#${fragment}.check'
      '' {})
    ];
  }
