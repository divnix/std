<div class="sidetoc"><nav class="pagetoc"></nav></div>

# Builtin Block Types

A few Block Types are packaged with `std`.

In practical terms, Block Types distinguish themselves through the
actions they provide to a particular Cell Block.

It is entirely possible to define custom Block Types with custom
Actions according to the needs of your project.

## Arion

```nix
{{#include ../../lib/blockTypes/arion.nix}}
```

## Runnables (todo: vs installables)

```nix
{{#include ../../lib/blockTypes/runnables.nix}}
```

## Installables (todo: vs runnables)

```nix
{{#include ../../lib/blockTypes/installables.nix}}
```

## Pkgs

```nix
{{#include ../../lib/blockTypes/pkgs.nix}}
```

## Devshells

```nix
{{#include ../../lib/blockTypes/devshells.nix}}
```

## Nixago

```nix
{{#include ../../lib/blockTypes/nixago.nix}}
```

## Containers

```nix
{{#include ../../lib/blockTypes/containers.nix}}
```

## Terra

Block type for managing [Terranix] configuration for [Terraform].

[Terranix]: https://terranix.org/
[Terraform]: https://www.terraform.io/

```nix
{{#include ../../src/blocktypes/terra.nix}}
```

## Data

```nix
{{#include ../../lib/blockTypes/data.nix}}
```

## Functions

```nix
{{#include ../../lib/blockTypes/functions.nix}}
```

## Anything

_Note: while the implementation is the same as `functions`, the semantics are different. Implementations may diverge in the future._

```nix
{{#include ../../lib/blockTypes/anything.nix}}
```
