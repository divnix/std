{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  A function that "up-lifts" your `std` targets.

  The transformation is: system.cell.block.target -> system.target

  You can typically use this function in a compatibility layer of soil.

  Example:

  ```nix
  # Soil ...
  # nix-cli compat
  {
    devShell = inputs.std.harvest inputs.self ["tullia" "devshell" "default"];
    defaultPackage = inputs.std.harvest inputs.self ["tullia" "apps" "tullia"];
  }
  ```
  */
  harvest = t: p: let
    multiplePaths = l.isList (l.elemAt p 0);
    hoist = path:
      l.mapAttrs (_: v: l.getAttrFromPath path v)
      (
        l.filterAttrs (
          n: v:
            (l.elem n l.systems.doubles.all) # avoids infinit recursion
            && (l.hasAttrByPath path v)
        )
        t
      );
  in
    if multiplePaths
    then l.foldl' l.recursiveUpdate {} (map (path: hoist path) p)
    else hoist p;
in
  harvest
