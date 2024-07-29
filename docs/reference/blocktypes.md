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

## Kubectl

Block type for rendering deployment manifests for the [Kubernetes] Cluster scheduler.
Each named attribtute-set under the block contains a set of deployment manifests.

[Kubernetes]: https://kubernetes.io

```nix
{{#include ../../src/std/fwlib/blockTypes/kubectl.nix}}
```

## Files (todo: vs data)

```nix
{{#include ../../src/std/fwlib/blockTypes/files.nix}}
```

## Microvms

Block type for managing [microvm.nix] configuration for declaring lightweight NixOS virtual machines.

[microvm.nix]: https://astro.github.io/microvm.nix

```nix
{{#include ../../src/std/fwlib/blockTypes/microvms.nix}}
```

## Namaka

Block type for declaring [Namaka] snapshot tests.

[Namaka]: https://github.com/nix-community/namaka

```nix
{{#include ../../src/std/fwlib/blockTypes/namaka.nix}}
```

## Nixostests

Block type for declaring VM-based tests for NixOS.

```nix
{{#include ../../src/std/fwlib/blockTypes/nixostests.nix}}
```

## Nomad

Block type for rendering job descriptions for the [Nomad] Cluster scheduler.

[Nomad]: https://www.nomadproject.io/

```nix
{{#include ../../src/std/fwlib/blockTypes/nomad.nix}}
```

## Nvfetcher

Block type for managing [nvfetcher] configuration for updating package definition sources.

[nvfetcher]: https://github.com/berberman/nvfetcher

```nix
{{#include ../../src/std/fwlib/blockTypes/nvfetcher.nix}}
```
