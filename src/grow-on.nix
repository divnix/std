{
  nixpkgs,
  yants,
}: let
  l = nixpkgs.lib // builtins;
  grow = import ./grow.nix {inherit nixpkgs yants;};
  growOn = args:
    grow args
    // {
      __functor = l.flip l.recursiveUpdate;
    };
in
  growOn
