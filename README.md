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

[Standard][std] standard doesn't just throw more options at you.
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

      - `/app.nix`

        ```nix
        { inputs
        , ...
        }:
        inputs.nixpkgs.stdenv.mkDerivation rec {
          pname = "hello";
          version = "2.10";
          src = inputs.nixpkgs.fetchurl {
            url = "mirror://gnu/hello/${pname}-${version}.tar.gz";
            sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
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

#### Cross compiling

[Cross compilation][cross_compiler] is a first class citizen in [Standard][std].

To the previous example,
let's add what systems
we would like to perform the builds on
and which systems are going to run (host) our application:

```diff
{
  inputs.std.url = "github:divnix/std";

  outputs = { std, ... } @ inputs:
    std.grow {
      inherit inputs;
      cellsFrom = ./cells;
+      systems = [
+        {
+          build = "x86_64-unknown-linux-gnu";  # GNU/Linux 64 bits
+          host = "i686-w64-mingw32";  # Windows 32 bits
+        }
+      ];
    };
}
```

You see, we are currently on Linux:

```bash
$ uname -ms
Linux x86_64
```

And we can build `hello` for Windows:

```bash
$ nix build /my/project#hello-i686-w64-mingw32
```

The result is indeed a Windows executable:

```bash
$ file ./result/bin/hello.exe
PE32 executable (console) Intel 80386 (stripped to external PDB), for MS Windows
```

Let's emulate Windows on Linux with `wine`:

```bash
$ wine ./result/bin/hello.exe
Hello, world!
```

May systems are supported :sparkles:

<!--
Update with:

echo -e $(nix-instantiate --eval --expr '
  let std = builtins.getFlake "'$PWD'";
  in builtins.concatStringsSep ",\n> " (builtins.attrNames std.systems)
')
-->

> <sub>
> aarch64-apple-darwin,
> aarch64-apple-ios,
> aarch64-none-elf,
> aarch64-unknown-linux-android,
> aarch64-unknown-linux-gnu,
> aarch64-unknown-linux-musl,
> aarch64_be-none-elf,
> arm-none-eabi,
> arm-none-eabihf,
> armv5tel-unknown-linux-gnueabi,
> armv6l-unknown-linux-gnueabihf,
> armv6l-unknown-linux-musleabihf,
> armv7a-apple-ios,
> armv7a-unknown-linux-androideabi,
> armv7l-unknown-linux-gnueabihf,
> avr,
> i686-apple-ios,
> i686-elf,
> i686-unknown-linux-gnu,
> i686-unknown-linux-musl,
> i686-w64-mingw32,
> js-unknown-ghcjs,
> m68k-unknown-linux-gnu,
> mipsel-unknown-linux-gnu,
> mipsel-unknown-linux-uclibc,
> mmix-unknown-mmixware,
> msp430-elf,
> or1k-elf,
> powerpc-none-eabi,
> powerpc64-unknown-linux-gnu,
> powerpc64-unknown-linux-musl,
> powerpc64le-unknown-linux-gnu,
> powerpc64le-unknown-linux-musl,
> powerpcle-none-eabi,
> riscv32-none-elf,
> riscv32-unknown-linux-gnu,
> riscv64-none-elf,
> riscv64-unknown-linux-gnu,
> s390-unknown-linux-gnu,
> s390x-unknown-linux-gnu,
> vc4-elf,
> wasm32-unknown-wasi,
> x86_64-apple-darwin,
> x86_64-apple-ios,
> x86_64-elf,
> x86_64-unknown-linux-gnu,
> x86_64-unknown-linux-musl,
> x86_64-unknown-netbsd,
> x86_64-unknown-redox,
> x86_64-w64-mingw32
> </sub>

## Examples

If you'd like to see some examples
of what a [Standard][std] project looks like,
take a look at the following:

- [Bitte Cells][bitte-cells]

:construction: Work in progress, would like to help us extend this section?

## Contributions

Please get ourself the appropriate environment:

### With `direnv`

```console
direnv allow
```

### Without `direnv`

```console
nix develop ./devshell#__default -c $SHELL
menu
```

---

[bitte-cells]: https://github.com/input-output-hk/bitte-cells
[cross_compiler]: https://en.wikipedia.org/wiki/Cross_compiler
[hydra]: https://github.com/NixOS/hydra
[nix_drv]: https://nixos.org/manual/nix/unstable/expressions/derivations.html
[nix_flakes]: https://nixos.wiki/wiki/Flakes
[nix]: https://nixos.org/manual/nix/unstable
[std]: https://github.com/divnix/std
