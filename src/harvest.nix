{nixpkgs}: let
  l = nixpkgs.lib // builtins;
  /*
  A function that "up-lifts" your `std` targets.

  The transformation is: system.cell.organelle.target -> system.target

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
