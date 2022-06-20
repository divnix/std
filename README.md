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

[Standard][std] is THE opinionated, generic,
[Nix][nix] [Flakes][nix-flakes] framework
that will allow you to grow and cultivate
Nix Cells with ease. Nix Cells are the fine
art of code organization using flakes.

_Once_ your `nix` code has evolved into a giant
ball of spaghetti and nobody else except a few
select members of your tribe can still read it
with ease; and _once_ to the rest of your colleagues
it has grown into an impertience, _then_ `std`
brings the overdue order to your piece of art
through a well-defined folder structure and
disciplining generic interfaces.

With `std`, you'll learn how to organize your `nix`
flake outputs ('**Targets**') into **Cells** and
**Organelles** &mdash; folded into a useful
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
- [`std.growOn`][grow-on]: `std.grow`-variant that recursively merges all additinonal variadic arguments
- [`std.harvest`][harvest]: harvest your **Targets** into a different shape for compatibility
- [`std.incl`][incl]: a straight-forward source filter with additive semantics
- [`std.deSystemize`][de-systemize]: a helper to hide `system` from plain sight
- [`std.<clade>`][clades]: builtin **Organelle** types that implement **Actions**

_What is this crazy verbiage? &rarr; Unambigous identifiers on the phone._ ☎️

### Application

_Dog-fooding? &rarr; [`./cells`][cells]._

- **Cells:** this is no big monorepo, so [`./cells`][cells] only implements a single **Cell**: [`std`][std-cell].
- **Organelles:** [`std`][std-cell] implements the [`cli`][cli-organelle],
  [`devshellProfiles`][devshellprofiles-organelle], [`devshells`][devshells-organelle]
  & [`lib`][lib-organelle] **Organelle**.
- **Targets:** [`cli`][cli-organelle], [`devshellProfiles`][devshellprofiles-organelle] & [`devshells`][devshells-organelle]
  each only implement a `default` **Target**. [`lib`][lib-organelle] has more.
- **Actions:** some **Targets** have **Actions** derived from the **Organelles**. See [`./flake.nix`][flake]
  for the defined **Organelles**. Not all **Clades** implement **Actions**.

```nix
{{#include ../dogfood.nix}}
```

_That's it. `std.grow` is a "smart" importer of your `nix` code and is designed to keep boilerplate at bay._

> **TIP:**
> Now, enter the devshell (`direnv allow`) and play with the `std` CLI/TUI companion.
> It answers one critical question to newcomers and vetarans alike:
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

If you'd like to see some examples
of what a [Standard][std] project looks like,
take a look at the following:

- [`input-output-hk/bitte-cells`][bitte-cells]
- [`divnix/hive`][divnix-hive]
- [`input-output-hk/tullia`][iog-tullia]
- [`mdbook-kroki-preprocessor`][mdbook-kroki-preprocessor]
- [`HardenedNixOS-Profile`][hardenednixos-profile]
- [`Julia2Nix.jl`][julia2nix]
- [`inputs-output-hk/cardano-world`][cardano-world]

:construction: Work in progress, would like to help us extend this section?

## Contributions

Please enter the development environment:

```console
direnv allow
```

---

[std-cell]: https://github.com/divnix/std/tree/main/cells/std
[cli-organelle]: https://github.com/divnix/std/blob/main/cells/std/cli.nix
[devshellprofiles-organelle]: https://github.com/divnix/std/blob/main/cells/std/devshellProfiles.nix
[devshells-organelle]: https://github.com/divnix/std/blob/main/cells/std/devshells.nix
[lib-organelle]: https://github.com/divnix/std/blob/main/cells/std/lib/default.nix
[cells]: https://github.com/divnix/std/tree/main/cells
[src]: https://github.com/divnix/std/tree/main/src
[docs]: https://github.com/divnix/std/tree/main/docs
[book]: https://divnix.github.io/std
[releases]: https://github.com/divnix/std/releases
[licensing]: https://github.com/divnix/std/blob/main/.reuse/dep5
[licenses]: https://github.com/divnix/std/tree/main/LICENSES
[grow]: https://github.com/divnix/std/blob/main/src/grow.nix
[grow-on]: https://github.com/divnix/std/blob/main/src/grow-on.nix
[harvest]: https://github.com/divnix/std/blob/main/src/harvest.nix
[incl]: https://github.com/divnix/std/blob/main/src/incl.nix
[de-systemize]: https://github.com/divnix/std/blob/main/src/de-systemize.nix
[clades]: https://github.com/divnix/std/blob/main/src/clades.nix
[flake]: https://github.com/divnix/std/blob/main/flake.nix
[yants]: https://github.com/divnix/yants
[bitte-cells]: https://github.com/input-output-hk/bitte-cells
[cardano-world]: https://github.com/input-output-hk/cardano-world
[divnix-hive]: https://github.com/divnix/hive
[hardenednixos-profile]: https://github.com/hardenedlinux/HardenedNixOS-Profile
[iog-tullia]: https://github.com/input-output-hk/tullia
[julia2nix]: https://github.com/JuliaCN/Julia2Nix.jl
[mdbook-kroki-preprocessor]: https://github.com/input-output-hk/mdbook-kroki-preprocessor
[nix-flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org/manual/nix/unstable
[std]: https://github.com/divnix/std
[why-std]: https://divnix.github.io/std/explain/why-std.html
[why-nix]: https://divnix.github.io/std/explain/why-nix.html
