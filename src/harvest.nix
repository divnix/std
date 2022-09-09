{winnow}:
/*
A function that "up-lifts" your `std` targets.

The transformation is: system.cell.block.target -> system.target

Semantically equivalent to winnow without a filter

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
winnow true
