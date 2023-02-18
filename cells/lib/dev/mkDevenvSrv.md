### `mkDevenvSrv`

This is a wrapper to make service definitions from [`cachix/devenv`][devenv] available to the devshell.

Devenv's `integrations` & `languages` are not compatible, and hence they are excluded from the module system.

[devenv]: https://devenv.sh/reference/options/
