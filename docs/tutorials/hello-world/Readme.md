# Hello World

[Standard][std] features a special project structure
that brings some awesome innovation
to this often overlooked (but important) part of your project.
With the default **Cell Blocks**, an `apps.nix` file tells [Standard][std]
that we are creating an Application.
`flake.nix` is in charge
of explicitly defining
the inputs of your project.

> _Btw, you can can copy \* the following files from [here][here]._
>
> \* _don't just clone the `std` repo: flakes in subfolders don't work that way._

#### `/tmp/play-with-std/hello-world/flake.nix`

```nix
{{#include ./flake.nix}}
```

#### `/tmp/play-with-std/hello-world/cells/hello/apps.nix`

```nix
{{#include ./cells/hello/apps.nix}}
```

```bash
$ cd /tmp/play-with-std/hello-world/
$ git init && git add . && git commit -m"nix flakes only can see files under version control"
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

### [Default `cellBlocks`][grow-nix-default-cellblocks]

```nix
{{#include ../../../src/grow.nix:64:68}}
```

### [Default `systems`][grow-nix-default-systems]

```nix
{{#include ../../../src/grow.nix:69:78}}
```

---

[std]: https://github.com/divnix/std
[here]: https://github.com/divnix/std/tree/main/docs/tutorials/hello-world
[grow-nix-default-cellblocks]: https://github.com/divnix/std/blob/main/src/grow.nix#L63-L67
[grow-nix-default-systems]: https://github.com/divnix/std/blob/main/src/grow.nix#L68-L77
