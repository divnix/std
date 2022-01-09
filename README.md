<div align="center">
  <img src="https://github.com/on-nix/std/raw/main/artwork/logo.png" width="250" />
  <h1>Standard</h1>
  <p>Ship today with architecture for tomorrow</span>
</div>

<!--
_By [Kevin Amado](https://github.com/kamadorueda),
with contributions from [David Arnold](https://github.com/blaggacao),
[Timothy DeHerrera](https://github.com/nrdxp)
and many more amazing people (see end of file for a full list)._
-->

[Standard][STD] is an opinionated, generic,
[Nix][NIX] [Flakes][NIX_FLAKES] framework
that will allow you to build and deploy with ease.
By making a lot of decisions for you,
[Standard][STD] lets you get to work
on what makes your application special,
instead of wasting cycles choosing
and re-choosing various technologies and configurations.
Plus, because [Standard][STD] is a proper framework,
you benefit from continued performance
and feature upgrades over time with minimum effort. :sparkles:

**Edge-ready**

[Standard][STD] is designed to be
deployable completely on the edge -
[AWS][AWS],
[Docker][DOCKER],
[GCP][GCP],
[GitHub][GITHUB],
[GitLab][GITLAB],
[Nomad][NOMAD],
[Hydra][HYDRA],
[Kubernetes][K8S],
among others.

**Code Organization**

[Standard][STD] has a pre-defined place
for all your code.
Packages, applications, functions, components, plugins:
they all have a home.

**Developer Experience**

[Standard][STD] projects
are as declarative as possible;
we eliminate most boilerplate;
zero-config workflows...
everything Just Works™.

## How it's organized

[Standard][STD] places all the code in a directory of your choice.

![](./artwork/model.png)

Related code is grouped into **Cells**
that can be composed together
to form any functionality you can imagine.

A Cell provides functionality through:
- Applications

  Instructions that can be run.
  For example: `cd`, `ls`, and `cat` are applications.
- Packages

  Contents (files and/or directories)
  generated in a pure and reproducible way,
  also known as [derivations][NIX_DRV].
- Functions

  Instructions on how to turn the given inputs
  into something else.

  They act like a library
  that you and others can use
  in order to abstract, share
  and re-use code.

### Hello World application

[Standard][STD] features a special project structure
that brings some awesome innovation
to this often overlooked (but important) part of your project.
An `app.nix` file tells [Standard][STD]
that we are creating an Application.
`flake.nix` is in charge
of explicitly defining
the inputs of your project.

- `/my/project`
  - `/flake.nix`

    ```nix
    {
      inputs.std.url = "github:on-nix/std";

      outputs = { std, ... } @ inputs:
        std.project {
          inherit inputs;
          outputsFrom = ./src;
        };
    }
    ```
  - `/src`
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

[Cross compilation][CROSS_COMPILER] is a first class citizen in [Standard][STD].

To the previous example,
let's add what systems
we would like to perform the builds on
and which systems are going to run (host) our application:

```diff
 {
   inputs.std.url = "github:on-nix/std";

   outputs = { std, ... } @ inputs:
     std.project {
       inherit inputs;
       outputsFrom = ./src;
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
of what a [Standard][STD] project looks like,
take a look at the following:

:construction: Work in progress, would like to help us extend this section?

---

[AWS]: https://aws.amazon.com
[CROSS_COMPILER]: https://en.wikipedia.org/wiki/Cross_compiler
[DOCKER]: https://www.docker.com
[GCP]: https://cloud.google.com
[GITHUB]: https://github.com
[GITLAB]: https://gitlab.com
[HYDRA]: https://github.com/NixOS/hydra
[K8S]: https://kubernetes.io
[NIX]: https://nixos.org/manual/nix/unstable
[NIX_DRV]: https://nixos.org/manual/nix/unstable/expressions/derivations.html
[NIX_FLAKES]: https://nixos.wiki/wiki/Flakes
[NOMAD]: https://www.nomadproject.io
[STD]: https://github.com/on-nix/std
