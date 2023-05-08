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

[Standard][std] is a nifty DevOps framework that
enables an efficient Software Development Life Cycle (SDLC) with the power of [Nix][nix] via [Flakes][nix-flakes].

It organizes and disciplines your Nix and thereby speeds you up.
It also comes with great horizontal integrations of high
quality vertical DevOps tooling crafted by the [Nix Ecosystem][ecosystem].

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
[![Numtide Treefmt](https://img.shields.io/badge/Numtide-Treefmt-yellow?style=for-the-badge&logo=NixOS)](https://github.com/numtide/treefmt)
[![Nlewo Nix2Container](https://img.shields.io/badge/Nlewo-Nix2Container-blue?style=for-the-badge&logo=NixOS)](https://github.com/nlewo/nix2container)
[![Fluidattacks Makes](https://img.shields.io/badge/Fluidattacks-Makes-blue?style=for-the-badge&logo=NixOS)](https://github.com/fluidattacks/makes)
[![Astro MicroVM](https://img.shields.io/badge/Astro-MicroVM-blue?style=for-the-badge&logo=NixOS)](https://github.com/astro/microvm.nix)
[![HerculesCI FlakeParts](https://img.shields.io/badge/HerculesCI-FlakeParts-lightgrey?style=for-the-badge&logo=NixOS)](https://github.com/hercules-ci/flake-parts)
[![Cachix Cache](https://img.shields.io/badge/Cachix-Cache-blue?style=for-the-badge&logo=NixOS)](https://github.com/cachix)
[![Nix-Community Nixago](https://img.shields.io/badge/NixCommunity-Nixago-yellow?style=for-the-badge&logo=NixOS)](https://github.com/nix-community/nixago)

###### The Standard Story

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

###### The Standard NixOS Story (in case you wondered)

_Once_ you got fed up with `divnix/digga`
or a disorganized personal configuration,
please head straight over to [`divnix/hive`][hive]
and join the chat, there. It's work in progress.
But hey! It means: we can progress together!

---

## Getting Started

```nix
# flake.nix
{
  description = "Description for the project";

  inputs = {
    std.url = "github:divnix/std";
    nixpkgs.follows = "std/nixpkgs";
  };

  outputs = { std, self, ...} @ inputs: std.growOn {
    inherit inputs;
    # 1. Each folder inside `cellsFrom` becomes a "Cell"
    #    Run for example: 'mkdir nix/mycell'
    # 2. Each <block>.nix or <block>/default.nix within it becomes a "Cell Block"
    #    Run for example: '$EDITOR nix/mycell/packages.nix' - see example content below
    cellsFrom = ./nix;
    # 3. Only blocks with these names [here: "packages" & "devshells"] are picked up by Standard
    #    It's a bit like the output type system of your flake project (hint: CLI & TUI!!)
    cellBlocks = with std.blockTypes; [
      (installables "packages" {ci.build = true;})
      (devshells "devshells" {ci.build = true;})
    ];
  }
  # 4. Run 'nix run github:divnix/std'
  # 'growOn' ... Soil:
  #  - here, compat for the Nix CLI
  #  - but can use anything that produces flake outputs (e.g. flake-parts or flake-utils)
  # 5. Run: nix run .
  {
    devShells = std.harvest self ["mycell" "devshells"];
    packages = std.harvest self ["mycell" "packages"];
  };
}

# nix/mycell/packages.nix
{inputs, cell}: {
  inherit (inputs.nixpkgs) hello;
  default = cell.packages.hello;
}
```

## This Repository

This repository combines the above mentioned stack components into the ready-to-use Standard framework.
It adds a curated collection of [**Block Types**][blocktypes] for DevOps use cases.
It further dogfoods itself and implements utilities in its own [**Cells**][cells].

###### Dogfooding

<sub>Only renders in the [Documentation][documentation].</sub>

```nix
{{#include ../dogfood.nix}}
```

_That's it. `std.grow` is a "smart" importer of your `nix` code and is designed to keep boilerplate at bay. In the so called "Soil" compatibility layer, you can do whatever your heart desires. For example put `flake-utils` or `flake-parts` patterns here. Or, as in the above example, just make your stuff play nicely with the Nix CLI._

> **TIP:**
>
> 1. Clone this repo `git clone https://github.com/divnix/std.git`
> 2. Install `direnv` & inside the repo, do: `direnv allow` (first time takes a little longer)
> 3. Run the TUI by entering `std` (first time takes a little longer)
>
> <center><i>What can I <b>do</b> with this repository?</i></center>
> &emsp;

## Documentation

The [Documentation][documentation] is here.

And here is the [Book][book], a very good walk-trough. Start here!

###### Video Series

- [Std - Introduction](https://www.loom.com/share/cf9d5d1a10514d65bf6b8287f7ddc7d6)
- [Std - Cell Blocks Deep Dive](https://www.loom.com/share/04fa1d578fd044059b02c9c052d87b77)
- [Std - Operables & OCI](https://www.loom.com/share/27d91aa1eac24bcaaaed18ea6d6d03ca)
- [Std - Nixago](https://www.loom.com/share/5c1badd77ab641d3b8e256ddbba69042)

###### Examples in the Wild

This [GitHub search query](https://github.com/search?q=%22divnix%2Fstd%22+path%3Aflake.nix&type=Code) holds a pretty good answer.

## Why?

- [Why `nix`?][why-nix]
- [Why `std`?][why-std]

## Contributions

Please enter the contribution environment:

```console
direnv allow || nix develop -c "$SHELL
```

## Licenses

_What licenses are used? &rarr; [`./.reuse/dep5`][licensing]._

_And the usual copies? &rarr; [`./LICENSES`][licenses]._

---

[cells]: https://github.com/divnix/std/tree/main/cells
[documentation]: https://std.divnix.com
[book]: https://jmgilman.github.io/std-book/
[licensing]: https://github.com/divnix/std/blob/main/.reuse/dep5
[licenses]: https://github.com/divnix/std/tree/main/LICENSES
[blocktypes]: https://github.com/divnix/std/blob/main/src/blocktypes.nix
[nix-flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org/manual/nix/unstable
[std]: https://github.com/divnix/std
[why-std]: https://std.divnix.com/explain/why-std.html
[why-nix]: https://std.divnix.com/explain/why-nix.html
[ecosystem]: https://discourse.nixos.org
[hive]: https://github.com/divnix/hive
