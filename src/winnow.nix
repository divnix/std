{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  A function that "up-lifts" your `std` targets.

  The transformation is: system.cell.block.target -> system.target

  The results are filtered based on the `pred` function

  You can typically use this function in a compatibility layer of soil.

  Example:

  ```nix
  # Soil ...
  # nix-cli compat
  {
    devShell = inputs.std.winnow (_: v: v != null) inputs.self ["tullia" "devshell" "default"];
    defaultPackage = inputs.std.winnow (n: _: n != "cli") inputs.self ["tullia" "apps" "tullia"];
  }
  ```
  */
  winnow = pred: t: p: let
    multiplePaths = l.isList (l.elemAt p 0);
    hoist = path:
      l.mapAttrs (
        _: v: let
          attr = l.getAttrFromPath path v;
        in
          # skip overhead if filtering is not needed
          if pred == true
          then attr
          else l.filterAttrs pred attr
      )
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
  winnow
