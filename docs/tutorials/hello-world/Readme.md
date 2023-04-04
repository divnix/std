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
{
  cellBlocks ? [
    (blockTypes.functions "library")
    (blockTypes.runnables "apps")
    (blockTypes.installables "packages")
  ],
  ...
} @ args:
```

### [Default `systems`][grow-nix-default-systems]

```nix
{
  systems ? [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ],
  ...
} @ cfg:
```

---

[std]: https://github.com/divnix/std
[here]: https://github.com/divnix/std/tree/main/docs/tutorials/hello-world
