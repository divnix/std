{
  inputs,
  std,
  flake-parts,
}:
builtins.mapAttrs (
  n: f: let
    action = builtins.removeAttrs ({
        terra = f n "myrepo";
      }
      .${n}
      or (f n)) ["__functor"];
    buildable = {drvPath = "drvPath";};
    targets = {
      runnables = buildable;
      installables = buildable;
      devshells = buildable;
      containers =
        buildable
        // {
          image = {
            name = "repo:tag";
            repo = "repo";
            tag = "tag";
            tags = ["tag" "tag2"];
          };
        };
    };
  in (
    if action ? actions
    then
      action
      // {
        actions = action.actions {
          inherit inputs;
          currentSystem = inputs.nixpkgs.system;
          fragment = "f.r.a.g.m.e.n.t";
          fragmentRelPath = "x86/f/r/a/g/m/e/n/t";
          target = targets.${n} or {};
        };
      }
    else action
  )
)
std.blockTypes
