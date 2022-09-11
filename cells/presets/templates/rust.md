# Standard, and Nix and Rust, oh my!

This template uses [Nix][nix] to create a sane development shell for
Rust projects, [Standard][std] for keeping your Nix code well organized,
[Fenix][fenix] for pulling the latest rust binaries via Nix, and
[Crane][crane] for building Rust projects in Nix incrementally, making
quick iteration a breeze.

Rust Analyzer is also wired up properly for immediate use from a
terminal based editor with language server support. Need one with
stellar Nix and Rust support? Try [Helix][helix]!

## Bootstrap

```bash
# make a new empty project dir
mkdir my-project
cd my-project

# grab the template
nix flake init -t github:divnix/std#rust

# do some inititialization
git init
cargo init # pass --lib for library projects
cargo build # to generate Cargo.lock
git add .
g commit -m "init"

# enter the devshell
direnv allow || nix develop
```

[std]: https://github.com/divnix/std#readme
[nix]: https://nixos.org
[fenix]: https://github.com/nix-community/fenix#readme
[crane]: https://github.com/ipetkov/crane#readme
[helix]: https://github.com/helix-editor/helix#readme
