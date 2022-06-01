# Why std?

## Problem

Nix is marvel to ones and cruelty to others.

Much of this professional schism is due to two fundamental issues:

- Nix is a functional language without typing
- Therefore, Nix-enthusiast seem to freeking love writing the most elegant and novel boilerplate all over again the next day.

The amount of domain specific knowledge required to untangle those most elegant and novel boilerplate patterns prevent
the other side of the schism, very understandibly, to see through the smoke the true beauty and benefits of `nix` as a
build and configuration language.

Lack of typing adds to the problem by forcing `nix`-practitioners to go out of their way (e.g. via [`divnix/yants`][yants]) to
add some internal boundaries and contracts to an ever morphing global context.

As a consequence, few actually _do_ that. And contracts across internal code boundaries are either absent or rudimentary or &mdash; yet again &mdash;
"elegant and novel". Neither of which satisfactorily settles the issue.

## Solution

`std` doesn't add language-level typing. But a well-balanced folder layout cut at 3 layers of conceptual
nesting provides the fundamentals for establishing internal boundaries.

> **Cell &rarr; Organelle &rarr; Target &rarr; [Action]**
>
> Where ...
>
> - **Cells** group functionality.
> - **Organelles** type outputs and implement **Actions**.
> - **Targets** name outputs.

Programmers are really good at pattern-abstraction when looking at two similar but slightly
different things: _**Cells** and **Organelles** set the stage for code readability._

**Organelles** only allow one possible interface: `{inputs, cell}`:

- `cell` the local **Cell**, promoting separation of concern
- `inputs` the `deSystemize`ed flake inputs &mdash; plus:
  - `inputs.self = self.sourceInfo;` reference source code in `nix`; filter with `std.incl`; don't misuse the global `self`.
  - `inputs.cells`: the other cells by name; code that documents its boundaries.
  - `inputs.nixpkgs`: an _instantiated_ `nixpkgs` for the current system;

Now, we have _organized_ `nix` code. Still, `nix` is not for everybody.
And for everybody else the `std` TUI/CLI companion answers a single question to perfection:

> **The GitOps Question:**
>
> <center><i>What can I actually <b>do</b> with this <code>std</code>-ized repository?</i></center>
> &emsp;

> **The Standard Answer:**
>
> <center><i><code>std</code> breaks down GitOps into a single UX-optimized TUI/CLI entrypoint.</i></center>
> &emsp;

## Benefit

Not everybody is going to love `nix` now.

But the ones, who know its secrets, now have an effective tool
to more empathically spark the joy.

Or simply: 💔 &rarr; 🧙 &rarr; 🔧 &rarr; ✨&rarr; 🏖️

The smallest common denominator, in any case:

> Only ever install a single dependency (`nix`) and reach _any_ repository target. Reproducibly.

[yants]: https://github.com/divnix/yants
