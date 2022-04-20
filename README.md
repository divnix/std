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

**DevOps Professionals,`nix`-loving**

[Standard][std] doesn't just throw more options at you.
It gives you and your team something much more valuable: _guidance_.

## How it's organized

[Standard][std] places all the code in a directory of your choice.

![](./artwork/model.png)

Related code is grouped into **Cells**
that can be composed together
to form any functionality you can imagine.

A Cell provides functionality through **Organelles** of **Clade**:

- Runnables
- Installables
- Functions
- Data

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

### Hello World application

[Standard][std] features a special project structure
that brings some awesome innovation
to this often overlooked (but important) part of your project.
With the default **Organelles**, an `app.nix` file tells [Standard][std]
that we are creating an Application.
`flake.nix` is in charge
of explicitly defining
the inputs of your project.

- `/my/project`

  - `/flake.nix`

    ```nix
    {
      inputs.std.url = "github:divnix/std";

      outputs = { std, ... } @ inputs:
        std.grow {
          inherit inputs;
          cellsFrom = ./cells;
        };
    }
    ```

  - `/cells`

    - `/hello`

      - `/apps.nix`

        ```nix
        { inputs
        , cell
        }:
        {
          default = inputs.nixpkgs.stdenv.mkDerivation rec {
            pname = "hello";
            version = "2.10";
            src = inputs.nixpkgs.fetchurl {
              url = "mirror://gnu/hello/${pname}-${version}.tar.gz";
              sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
            };
          };
        }
        ```

```bash
$ nix run /my/project#hello
Hello, world!
```

You see? from nothing
to running your first application
in just a few seconds :sparkles:

## Examples

If you'd like to see some examples
of what a [Standard][std] project looks like,
take a look at the following:

- [Bitte Cells][bitte-cells]
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

[bitte-cells]: https://github.com/input-output-hk/bitte-cells
[cross_compiler]: https://en.wikipedia.org/wiki/Cross_compiler
[divnix-hive]: https://github.com/divnix/hive
[hydra]: https://github.com/NixOS/hydra
[nix_drv]: https://nixos.org/manual/nix/unstable/expressions/derivations.html
[nix_flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org/manual/nix/unstable
[std]: https://github.com/divnix/std
