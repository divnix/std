# 5. Nixpkgs is still special, but not too much

Date: 2022-05-01

## Status

accepted

## Context

> What is the issue that we're seeing that is motivating this decision or change?

<!-- write an answer to this question below -->

In general, Standard wouldn't treat any intput as special.
However, no project that requires source distributions of one of the 80k+ packages available in `nixpkgs` can practically do without it.

Now, `nixpkgs` has this weird and counter-intuitive mouthful of `legacyPackages`, which was originally intended to ring an alarm bell and, for the non-nix-historians, still does.

Also, not very many other package collections adopt this idiom which makes it pretty much a singularity of the Nix package collection (`nixpkgs`).

## Decision

> What is the change that we're proposing and/or doing?

<!-- write an answer to this question below -->

If `inputs.nixpkgs` is provided, in-scope `legacyPackages` onto `inputs.nixpkgs`, directly.

## Consequences

> What becomes easier or more difficult to do because of this change?

<!-- write an answer to this question below -->

Users of Standard access packages as `nixpkgs.<package-name>`.

Users that want to interact with nixos, do so by loading `nixos = import (inputs.nixpkgs + "/nixos");` or similar.
The close coupling of the Nix Package Collection and NixOS now is broken.
This suites well the DevOps use case, which is not _primarily_ concerned with the unseparable union of the Nix Packages Collection and NixOS.
It rather presents a plethora of use cases that content with the Nix Package Collection, alone, and where NixOS would present as a distraction.
Now, this separation is more _explicit_.

As another consequence of not treating `nixpkgs` (or even the packaging use case) special is that Standard does not implement primary support for `overlays`.
