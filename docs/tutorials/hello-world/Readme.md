# Hello World

[Standard][std] features a special project structure
that brings some awesome innovation
to this often overlooked (but important) part of your project.
With the default **Organelles**, an `apps.nix` file tells [Standard][std]
that we are creating an Application.
`flake.nix` is in charge
of explicitly defining
the inputs of your project.

#### `./flake.nix`

```nix
{{#include ./flake.nix}}
```

#### `./cells/hello/apps.nix`

```nix
{{#include ./cells/hello/apps.nix}}
```

```bash
$ cd hello-world
# fetch `std`
$ nix shell github:divnix/std
$ std //hello/apps/default:run
Hello, world!
```

You see? from nothing
to running your first application
in just a few seconds ✨

## Assumptions

This example consumes the following defaults or builtins:

### [Default `organelles`][grow-nix-default-organelles]

```nix
{{#include ../../../src/grow.nix:63:67}}
```

### [Default `systems`][grow-nix-default-systems]

```nix
{{#include ../../../src/grow.nix:68:77}}
```

---

[std]: https://github.com/divnix/std
[grow-nix-default-organelles]: https://github.com/divnix/std/blob/main/src/grow.nix#L63-L67
[grow-nix-default-systems]: https://github.com/divnix/std/blob/main/src/grow.nix#L68-L77
