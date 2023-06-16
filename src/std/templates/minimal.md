# A minimal project template with docs!

## Included Configuration

- [`devshell`][devshell] for your contribution environments!
- [`treefmt`][treefmt] for formatting all the things!
- [`mdbook`][mdbook] for making documentation part of your workflow!
- [`lefthook`][lefthook] for commit discipline and a clean history!
- [GitHub Setting App][settings] for configuring GitHub declaratively!

[devshell]: https://numtide.github.io/devshell/
[treefmt]: https://numtide.github.io/treefmt/
[mdbook]: https://rust-lang.github.io/mdBook/
[lefthook]: https://github.com/evilmartians/lefthook
[settings]: https://github.com/apps/settings

## Bootstrap

```bash
# make a new empty project dir
mkdir my-project
cd my-project

# grab the template
nix flake init -t github:divnix/std#minimal

# see which values to change
grep -r --include=\*.nix 'CONFIGURE-ME' .

# do some inititialization
git init && git add .

# enter the devshell and effectuate repo configuration
direnv allow

git add . && git commit -m "feat: initial commit"
```
