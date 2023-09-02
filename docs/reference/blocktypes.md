<div class="sidetoc"><nav class="pagetoc"></nav></div>

# Builtin Block Types

A few Block Types are packaged with `std`.

In practical terms, Block Types distinguish themselves through the
actions they provide to a particular Cell Block.

It is entirely possible to define custom Block Types with custom
Actions according to the needs of your project.

## Arion

```nix
{{#include ../../src/std/fwlib/blockTypes/arion.nix}}
```

## Runnables (todo: vs installables)

```nix
{{#include ../../src/std/fwlib/blockTypes/runnables.nix}}
```

## Installables (todo: vs runnables)

```nix
{{#include ../../src/std/fwlib/blockTypes/installables.nix}}
```

## Pkgs

```nix
{{#include ../../src/std/fwlib/blockTypes/pkgs.nix}}
```

## Devshells

```nix
{{#include ../../src/std/fwlib/blockTypes/devshells.nix}}
```

## Nixago

```nix
{{#include ../../src/std/fwlib/blockTypes/nixago.nix}}
```

## Containers

```nix
{{#include ../../src/std/fwlib/blockTypes/containers.nix}}
```

## Terra

Block type for managing [Terranix] configuration for [Terraform].

[Terranix]: https://terranix.org/
[Terraform]: https://www.terraform.io/

```nix
{{#include ../../src/std/fwlib/blockTypes/terra.nix}}
```

## Data

```nix
{{#include ../../src/std/fwlib/blockTypes/data.nix}}
```

## Functions

```nix
{{#include ../../src/std/fwlib/blockTypes/functions.nix}}
```

## Anything

_Note: while the implementation is the same as `functions`, the semantics are different. Implementations may diverge in the future._

```nix
{{#include ../../src/std/fwlib/blockTypes/anything.nix}}
```
