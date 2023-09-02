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
      subdir = target.snap-dir or "";
    in [
      (mkCommand currentSystem "eval" "use transparently with namaka cli" [] ''
        nix eval '.#${fragment}.check'
      '' {})
      (mkCommand currentSystem "check" "run namaka tests against snapshots" [pkg] ''
        namaka "${subdir}" check -c nix eval '.#${fragment}.check'
      '' {})
      (mkCommand currentSystem "review" "review pending namaka checks" [pkg] ''
        namaka "${subdir}" review -c nix eval '.#${fragment}.check'
      '' {})
      (mkCommand currentSystem "clean" "clean up pending namaka checks" [pkg] ''
        namaka "${subdir}" clean -c nix eval '.#${fragment}.check'
      '' {})
    ];
  }
