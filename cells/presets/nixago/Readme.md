# The `std` Nixago Pebbles

Standard comes packages with some [Nixago][nixago] Pebbles for easy
downstream re-use.

Some Pebbles may have a special integration for `std`.

For example, the `conform` Pebble can undestand `inputs.cells`
and add each Cell as a so called "scope" to its
[Conventional Commit][conventional-commit] configuration.

[nixago]: https://github.com/nix-community/nixago
[conform]: conform.md
[conventional-commit]: https://www.conventionalcommits.org/
