# Documentation

[Introduction](README.md)

# Tutorials

# How-To Guides

- [Hello World](guides/hello-world/Readme.md)
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
    - [`/mkNixago`](reference/std/lib/mkNixago.md)

- [`//automation`]()

  - [`/devshells`](reference/automation/devshells/Readme.md)
