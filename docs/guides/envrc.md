# Setup `.envrc`

Standard provides an extension to the `stdlib` via `direnv_lib.sh`.

The integrity hash below ensures it is downloaded only once and cached
from there on.

```bash
{{#include ../../.envrc}}
```

> **NOTE:**
> In the above code `use std` **`cells`** `//std/...` refers to the
> folder where **Cells** are grown from. If your folder is e.g. `nix`, adapt
> to `use std` **`nix`** `//...` and so forth.

It is used to automatically set up file watches on files that could modify the
current devshell, discoverable through these or similar logs during loading:

```console
direnv: loading https://raw.githubusercontent.com/divnix/std/...
direnv: using std cells //automation/devshells:default
direnv: Watching: cells/automation/devshells.nix
direnv: Watching: cells/automation/devshells (recursively)
```

For reference, the above example loads the `default` devshell from:

```nix
{{#include ../../cells/automation/devshells.nix}}
```
