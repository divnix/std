### `conform`

[Conform][conform] your code to policies, e.g. in a pre-commit hook.

This version is wrapped, it can auto-enhance the conventional
commit scopes with your `cells` as follows:

```nix
{ inputs, cell}: let
  inherit (inputs.std) lib;
in {

  default = lib.dev.mkShell {
    /* ... */
    nixago = [
      (lib.cfg.conform {data = {inherit (inputs) cells;};})
    ];
  };
}
```

[conform]: https://github.com/siderolabs/conform

---

#### Definition:

```nix
{{#include ./../../../../cells/lib/cfg/conform.nix}}
```
