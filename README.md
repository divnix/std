<!--
SPDX-FileCopyrightText: 2022 The Standard Authors
SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>

SPDX-License-Identifier: Unlicense
-->

<div align="center">
  <img src="https://github.com/divnix/std/raw/main/artwork/logo.png" width="250" />
  <h1>Standard</h1>
  <p>Ship today with architecture for tomorrow</span>
</div>

<!--
_By [Kevin Amado](https://github.com/kamadorueda),
with contributions from [David Arnold](https://github.com/blaggacao),
[Timothy DeHerrera](https://github.com/nrdxp)
and many more amazing people (see end of file for a full list)._
-->

[Standard][std] is THE opinionated, generic,
[Nix][nix] [Flakes][nix_flakes] framework
that will allow you to grow and cultivate
Nix Cells with ease.

Nix Cells are the fine art of code organization
using flakes.

As a Nix Cell Cultivator, you can focus on building
for your use cases and ride on the marvels of nix flakes
while wasting virtually no thoughts on boilerplate
code organization.

Because [Standard][std] is a proper framework,
you benefit from continued performance
and feature upgrades over time with minimum effort. :sparkles:

**Code Organization**

[Standard][std] has a pre-defined place
for all your code.
Packages, applications, functions, libraries, modules, profiles:
they all have a home.

**Developer Experience**

[Standard][std] projects
are as declarative as possible;
we eliminate most boilerplate;
zero-config workflows...
everything Just Works™.

**DevOps Professionals**

[Standard][std] doesn't just throw more options at you.
It gives you and your team something much more valuable: _guidance_.

**Discoverability & Gamification**

[Standard][std]'s companion TUI/CLI `std` focuses on polyglot
discoverability of your repository's targets & actions. Build
a package, run a test, publish an artifact... Explore what's
available with style! 😎

## How it's organized

[Standard][std] places all the code in a directory of your choice.

Then, with just very few hints, Standard undestands your codebase
and let you and others easily discover what your code base has to
offer. Almost like gitops-gamification.

![](./artwork/model.png)

Related code is grouped into **Cells**
that can be composed together
to form any functionality you can imagine.

A Cell provides functionality through **Organelles** of **Clade**:

- Runnables
- Installables
- Functions
- Data

You can even define your own clades. The standard clades already
define a set of actions that can be run on such clades. Check them
out in [`./src/clades.nix`][clades-nix]

The built-in default **Organelles** are:

- Applications (Runnables)

  Instructions that can be run.
  For example: `cd`, `ls`, and `cat` are applications.

- Packages (Installables)

  Contents (files and/or directories)
  generated in a pure and reproducible way,
  also known as [derivations][nix_drv].

- Libraries (Functions)

  Instructions on how to turn the given inputs
  into something else.

  They act like a library
  that you and others can use
  in order to abstract, share
  and re-use code.

A potential alternative to the default **Organelle** _types_ could be:

- NixOS Modules (Functions)
- NixOS Profiles (Functions)
- DevShell Profiles (Functions)
- Just Tasks (Runnables)
- Entrypoints (Runnables)

## Documentation

Please go through the annotated source code:

- [`./src/grow.nix`][grow-nix]
- [`./src/incl.nix`][incl-nix]
- [`./src/de-systemize.nix`][de-systemize-nix]
- [`./src/clades.nix`][clades-nix]

Then, this repo also is [Standard][std]ized and you can explore
it functionality, including documentation by entering the Devshell
and just type `std`.

Or consume the doc page under: [https://divnix.github.io/std][std-docs]

## Examples in the Wild

If you'd like to see some examples
of what a [Standard][std] project looks like,
take a look at the following:

- [`input-output-hk/bitte-cells`][bitte-cells]
- [`divnix/hive`][divnix-hive]

:construction: Work in progress, would like to help us extend this section?

## Contributions

Please get ourself the appropriate environment:

### With `direnv`

```console
direnv allow
```

### Without `direnv`

```console
nix develop ./devshell -c $SHELL
menu
```

---

[clades-nix]: https://github.com/divnix/std/blob/main/src/clades.nix
[grow-nix]: https://github.com/divnix/std/blob/main/src/grow.nix
[incl-nix]: https://github.com/divnix/std/blob/main/src/incl.nix
[de-systemize-nix]: https://github.com/divnix/std/blob/main/src/de-systemize.nix
[bitte-cells]: https://github.com/input-output-hk/bitte-cells
[cross_compiler]: https://en.wikipedia.org/wiki/Cross_compiler
[divnix-hive]: https://github.com/divnix/hive
[hydra]: https://github.com/NixOS/hydra
[nix_drv]: https://nixos.org/manual/nix/unstable/expressions/derivations.html
[nix_flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org/manual/nix/unstable
[std]: https://github.com/divnix/std
[std-docs]: https://divnix.github.io/std
