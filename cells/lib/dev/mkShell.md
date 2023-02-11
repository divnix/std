### `mkShell`

This is a transparent convenience proxy for [`numtide/devshell`'s][numtide-devshell] `mkShell` function.

It is enriched with a tight integration for `std` [Nixago][nixago] pebbles:

```nix
{ inputs, cell}: {
  default = inputs.std.lib.dev.mkShell {
    /* ... */
    nixago = [
      (cell.nixago.foo {
        data.qux = "xyz";
        packages = [ pkgs.additional-package ];
      })
      cell.nixago.bar
      cell.nixago.quz
    ];
  };
}
```

_Note, that you can extend any Nixago Pebble at the calling site
via a built-in functor like in the example above._

[nixago]: https://github.com/nix-community/nixago
[numtide-devshell]: https://github.com/numtide/devshell
