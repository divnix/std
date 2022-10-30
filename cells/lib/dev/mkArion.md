# `mkArion`

This is a transparent convenience proxy for [`hercules-ci/arion`'s][arion] `lib.build` function.

However, the arion's `nixos` config option was removed.

As Standard claims to be the integration layer it will not delegate integration via a foreign
interface to commissioned tools, such as arion.

This is a bridge towards and from docker-compose users. Making nixos part of the interface would
likely alienate that bridge for those users.

If you need a nixos-based container image, please check out the arion source code on how it's done.

[arion]: https://github.com/hercules-ci/arion
