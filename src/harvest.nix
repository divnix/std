{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  harvest = t: p:
    l.mapAttrs (_: v: l.getAttrFromPath p v)
    (
      l.filterAttrs (
        n: v:
          (l.elem n l.systems.doubles.all) # avoids infinit recursion
          && (l.hasAttrByPath p v)
      )
      t
    );
in
  harvest
