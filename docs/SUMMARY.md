# Documentation

[Introduction](README.md)

# Tutorials

- [Hello World](tutorials/hello-world/Readme.md)
- [Hello Moon](tutorials/hello-moon/Readme.md)

# How-To Guides

- [Growing Cells](guides/growing-cells.md)
- [Include Filter](guides/incl.md)
- [Setup `.envrc`](guides/envrc.md)

# Explanation

- [Why `nix`?](explain/why-nix.md)

- [Why `std`?](explain/why-std.md)

- [Architecture Decisions](explain/architecture-decision-records/Readme.md)
  - [0001 Drop `as-nix-cli-epiphyte` flag](explain/architecture-decision-records/0003-drop-as-nix-cli-epiphyte-flag.md)
  - [0002 Wire Up Documentation Instrumentation](explain/architecture-decision-records/0002-wire-up-documentation-instrumentation.md)
  - [0003 Increase Repo Discoverability With a Tui](explain/architecture-decision-records/0001-increase-repo-discoverability-with-a-tui.md)
  - [0004 Add Nixago Instrumentation](explain/architecture-decision-records/0004-add-nixago-instrumentation.md)

# Patterns

- [The 4 Packaging Layers](patterns/four-packaging-layers.md)

# Reference

- [TUI/CLI](reference/cli.md)
- [Conventions](reference/conventions.md)
- [Builtin Clades](reference/clades.md)

  - [Data](reference/clades/data-clade.md)
  - [Functions](reference/clades/functions-clade.md)
  - [Runnables](reference/clades/runnables-clade.md)
  - [Installables](reference/clades/installables-clade.md)
  - [Microvms](reference/clades/microvms-clade.md)
  - [Devshells](reference/clades/devshells-clade.md)
  - [Containers](reference/clades/containers-clade.md)
  - [Nixago](reference/clades/nixago-clade.md)

- [`//std`](reference/std/Readme.md)

  - [`/cli`](reference/std/cli/Readme.md)
  - [`/devshellProfiles`](reference/std/devshellProfiles/Readme.md)
  - [`/lib`](reference/std/lib/Readme.md)
    - [`/fromMakesWith`](reference/std/lib/fromMakesWith.md)
    - [`/mkShell`](reference/std/lib/mkShell.md)
    - [`/writeShellEntrypoint`](reference/std/lib/writeShellEntrypoint.md)
    - [`/mkNixago`](reference/std/lib/mkNixago.md)
  - [`/nixago`](reference/std/nixago/Readme.md)
    - [`/adrgen`](reference/std/nixago/adrgen.md)
    - [`/conform`](reference/std/nixago/conform.md)
    - [`/editorconfig`](reference/std/nixago/editorconfig.md)
    - [`/lefthook`](reference/std/nixago/lefthook.md)
    - [`/mdbook`](reference/std/nixago/mdbook.md)
    - [`/treefmt`](reference/std/nixago/treefmt.md)

- [`//automation`]()

  - [`/devshells`](reference/automation/devshells/Readme.md)

- [Glossary](glossary.md)
