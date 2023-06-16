### `mkNixago`

This is a transparent convenience proxy for [`nix-community/nixago`'s][nixago] `lib.${system}.make` function.

It is enriched with a forward contract towards `std` enriched `mkShell` implementation.

In order to define [`numtide/devshell`'s][numtide-devshell] `commands` & `packages` alongside the Nixago pebble,
just add the following attrset to the Nixago spec. It will be picked up automatically by `mkShell` when that pebble
is used inside its `config.nixago`-option.

```nix
{ inputs, cell }: {
  foo = inputs.std.lib.dev.mkNixago {
    /* ... */
    packages = [ /* ... */ ];
    commands = [ /* ... */ ];
    devshell = { /* ... */ }; # e.g. for startup hooks
  };
}
```

[nixago]: https://github.com/nix-community/nixago
[numtide-devshell]: https://github.com/numtide/devshell
