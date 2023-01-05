<!--
SPDX-FileCopyrightText: 2022 The Standard Authors
SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>

SPDX-License-Identifier: Unlicense
-->

<div align="center">
  <img src="https://github.com/divnix/std/raw/main/artwork/logo.png" width="250" />
  <h1>Standard</h1>
  <p>Ship today.</span>
</div>

<!--
_By [Kevin Amado](https://github.com/kamadorueda),
with contributions from [David Arnold](https://github.com/blaggacao),
[Timothy DeHerrera](https://github.com/nrdxp)
and many more amazing people (see end of file for a full list)._
-->

---

[![Support room on Matrix](https://img.shields.io/matrix/std-nix:matrix.org?server_fqdn=matrix.org&style=for-the-badge)](https://matrix.to/#/#std-nix:matrix.org)

###### Stack

[![Yants](https://img.shields.io/badge/DivNix-Yants-green?style=for-the-badge&logo=NixOS)](https://github.com/divnix/yants)
[![DMerge](https://img.shields.io/badge/DivNix-DMerge-yellow?style=for-the-badge&logo=NixOS)](https://github.com/divnix/data-merge)
[![NoSys](https://img.shields.io/badge/DivNix-NoSys-orange?style=for-the-badge&logo=NixOS)](https://github.com/divnix/nosys)
[![Blank](https://img.shields.io/badge/DivNix-Blank-grey?style=for-the-badge&logo=NixOS)](https://github.com/divnix/blank)
[![Incl](https://img.shields.io/badge/DivNix-Incl-blue?style=for-the-badge&logo=NixOS)](https://github.com/divnix/incl)
[![Paisano](https://img.shields.io/badge/DivNix-Paisano-red?style=for-the-badge&logo=NixOS)](https://github.com/divnix/paisano)

###### Integrations

[![Numtide Devshell](https://img.shields.io/badge/Numtide-Devshell-yellowgreen?style=for-the-badge&logo=NixOS)](https://github.com/numtide/devshell)
[![Nlewo Nix2Container](https://img.shields.io/badge/Nlewo-Nix2Container-blue?style=for-the-badge&logo=NixOS)](https://github.com/nlewo/nix2container)
[![Fluidattacks Makes](https://img.shields.io/badge/Fluidattacks-Makes-blue?style=for-the-badge&logo=NixOS)](https://github.com/fluidattacks/makes)
[![Astro MicroVM](https://img.shields.io/badge/Astro-MicroVM-blue?style=for-the-badge&logo=NixOS)](https://github.com/astro/microvm.nix)
[![HerculesCI FlakeParts](https://img.shields.io/badge/HerculesCI-FlakeParts-lightgrey?style=for-the-badge&logo=NixOS)](https://github.com/hercules-ci/flake-parts)
[![Cachix Cache](https://img.shields.io/badge/Cachix-Cache-blue?style=for-the-badge&logo=NixOS)](https://github.com/cachix)

---

[Standard][std] is THE opinionated, generic,
[Nix][nix] [Flakes][nix-flakes] framework
that will allow you to grow and cultivate
Nix Cells with ease. Nix Cells are the fine
art of code organization using flakes.

_Once_ your `nix` code has evolved into a giant
ball of spaghetti and nobody else except a few
select members of your tribe can still read it
with ease; and _once_ to the rest of your colleagues
it has grown into an impertinence, _then_ `std`
brings the overdue order to your piece of art
through a well-defined folder structure and
disciplining generic interfaces.

With `std`, you'll learn how to organize your `nix`
flake outputs ('**Targets**') into **Cells** and
**Cell Blocks** &mdash; folded into a useful
**CLI & TUI** to also make the lives of your
colleagues easier.

Through more intuition and less documentation,
your team and community will finally find a
_canonical_ answer to the everlasting question:
_What can I **do** with this repository?_

---

## The `std` repository itself

In this repository, you'll find, both, the _implementation_ and an _application_ of [Standard][std].

### Implementation

_What is `std`? &mdash; The well-commented `nix` code &rarr; [`./src`][src]._

That folder implements:

- [`std.grow`][grow]: the "smart" importer
- [`std.growOn`][grow-on]: `std.grow`-variant that recursively merges all additional variadic arguments
- [`std.harvest`][harvest]: harvest your **Targets** into a different shape for compatibility
- [`std.winnow`][winnow]: when more advanced harvesting is required, use this to harvest _and_ filter the output
- [`std.pick`][pick]: pick your **Targets** into a different shape without system scope
- [`std.incl`][incl]: a straight-forward source filter with additive semantics
- [`std.deSystemize`][de-systemize]: a helper to hide `system` from plain sight
- [`std.<blockType>`][blocktypes]: builtin **(Cell) Block Types** that implement **(Cell Block Type) Actions**

### Application

_Dog-fooding? &rarr; [`./cells`][cells]._

- **Cells:** [`./cells`][cells] mainly implements [`std`][cell-std].
- **Cell Blocks:** [`std`][cell-std] implements:
  - [`cli`][block-cli];
  - [`devshellProfiles`][block-devshellprofiles];
  - [`nixago`][block-nixago]; and
  - [`lib`][block-lib].
- **Targets:** each Cell Block implements one or various targets.
- **Block Type Actions:** some **Targets** expose **Actions** inferred from the **Block Type**.

```nix
{{#include ../dogfood.nix}}
```

_That's it. `std.grow` is a "smart" importer of your `nix` code and is designed to keep boilerplate at bay._

> **TIP:**
> Now, enter the devshell (`direnv allow`) and play with the `std` CLI/TUI companion.
> It answers one critical question to newcomers and veterans alike:
>
> <center><i>What can I <b>do</b> with this repository?</i></center>
> &emsp;

### Documentation

_Where can I find the documentation? &rarr; [`./docs`][docs]._

_No, I mean rendered? &rarr; [The Standard Book][book]._

The documentation is structured around these axes:

|                  | For Study   | For Work      |
| ---------------- | ----------- | ------------- |
| **The Practice** | Tutorials   | How-To Guides |
| **The Theory**   | Explanation | Reference     |

### Licenses

_What licenses are used? &rarr; [`./.reuse/dep5`][licensing]._

_And the usual copies? &rarr; [`./LICENSES`][licenses]._

## Releases

You may find releases on the [GitHub Release Page][releases] of this repository.

## Why?

- [Why `nix`?][why-nix]
- [Why `std`?][why-std]

## Examples in the Wild

This [GitHub search query](https://github.com/search?p=7&q=%22divnix%2Fstd%22+filename%3Aflake.nix&type=Code) holds a pretty good answer.

## Explainer Video Series

- [Std - Introduction](https://www.loom.com/share/cf9d5d1a10514d65bf6b8287f7ddc7d6)
- [Std - Cell Blocks Deep Dive](https://www.loom.com/share/04fa1d578fd044059b02c9c052d87b77)
- [Std - Operables & OCI](https://www.loom.com/share/27d91aa1eac24bcaaaed18ea6d6d03ca)
- [Std - Nixago](https://www.loom.com/share/5c1badd77ab641d3b8e256ddbba69042)

## Contributions

Please enter the development environment:

```console
direnv allow
```

---

[cell-std]: https://github.com/divnix/std/tree/main/cells/std
[block-cli]: https://github.com/divnix/std/blob/main/cells/std/cli.nix
[block-devshellprofiles]: https://github.com/divnix/std/blob/main/cells/std/devshellProfiles.nix
[block-nixago]: https://github.com/divnix/std/blob/main/cells/std/nixago.nix
[block-lib]: https://github.com/divnix/std/blob/main/cells/std/lib/default.nix
[cells]: https://github.com/divnix/std/tree/main/cells
[src]: https://github.com/divnix/std/tree/main/src
[docs]: https://github.com/divnix/std/tree/main/docs
[book]: https://std.divnix.com
[releases]: https://github.com/divnix/std/releases
[licensing]: https://github.com/divnix/std/blob/main/.reuse/dep5
[licenses]: https://github.com/divnix/std/tree/main/LICENSES
[grow]: https://github.com/divnix/std/blob/main/src/grow.nix
[grow-on]: https://github.com/divnix/std/blob/main/src/grow-on.nix
[harvest]: https://github.com/divnix/std/blob/main/src/harvest.nix
[winnow]: https://github.com/divnix/std/blob/main/src/winnow.nix
[pick]: https://github.com/divnix/std/blob/main/src/pick.nix
[incl]: https://github.com/divnix/incl
[de-systemize]: https://github.com/divnix/nosys/blob/master/flake.nix
[blocktypes]: https://github.com/divnix/std/blob/main/src/blocktypes.nix
[flake]: https://github.com/divnix/std/blob/main/flake.nix
[yants]: https://github.com/divnix/yants
[bitte-cells]: https://github.com/input-output-hk/bitte-cells
[cardano-world]: https://github.com/input-output-hk/cardano-world
[divnix-hive]: https://github.com/divnix/hive
[hardenednixos-profile]: https://github.com/hardenedlinux/HardenedNixOS-Profile
[iog-tullia]: https://github.com/input-output-hk/tullia
[julia2nix]: https://github.com/JuliaCN/Julia2Nix.jl
[nix-flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org/manual/nix/unstable
[std]: https://github.com/divnix/std
[why-std]: https://std.divnix.com/explain/why-std.html
[why-nix]: https://std.divnix.com/explain/why-nix.html
