# [`conform`][conform]

Conform your code to policies, e.g. in a pre-commit hook.

This version is wrapped, it can auto-enhance the conventional
commit scopes with your `cells` as follows:

```nix
{ inputs, cell}: let
  inherit (inputs.std) std;
in {

  default = std.lib.mkShell {
    /* ... */
    nixago = [
      (std.nixago.conform {configData = {inherit (inputs) cells;};})
    ];
  };
}
```

[conform]: https://github.com/siderolabs/conform

---

#### Definition:

```nix
{{#include ./../../../../cells/std/nixago/conform.nix}}
```
