{harvest}:
/*
A function that "up-lifts" your `std` targets and devoids it of its system
scoping by simply picking the first system.

The transformation is: system.cell.block.target -> target

Use this if the system scopeing is not only irrelevant but also must go away.

Example:

```nix
# Soil ...
# nix-cli compat
{
  templates = inputs.std.pick inputs.self ["presets" "templates"];
}
```
*/
let
  pick = t: p: let
    r = harvest t p;
    s = builtins.head (builtins.attrNames r);
  in
    r.${s};
in
  pick
