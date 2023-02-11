<div class="sidetoc"><nav class="pagetoc"></nav></div>

# Builtin Block Types

A few Block Types are packaged with `std`.

In practical terms, Block Types distinguish themselves through the
actions they provide to a particular Cell Block.

It is entirely possible to define custom Block Types with custom
Actions according to the needs of your project.

## Arion

```nix
{{#include ../../src/blocktypes/arion.nix}}
```

## Runnables (todo: vs installables)

```nix
{{#include ../../src/blocktypes/runnables.nix}}
```

## Installables (todo: vs runnables)

```nix
{{#include ../../src/blocktypes/installables.nix}}
```

## Pkgs

```nix
{{#include ../../src/blocktypes/pkgs.nix}}
```

## Devshells

```nix
{{#include ../../src/blocktypes/devshells.nix}}
```

## Nixago

```nix
{{#include ../../src/blocktypes/nixago.nix}}
```

## Containers

```nix
{{#include ../../src/blocktypes/containers.nix}}
```

## Data

```nix
{{#include ../../src/blocktypes/data.nix}}
```

## Functions

```nix
{{#include ../../src/blocktypes/functions.nix}}
```

## Anything

_Note: while the implementation is the same as `functions`, the semantics are different. Implementations may diverge in the future._

```nix
{{#include ../../src/blocktypes/anything.nix}}
```
