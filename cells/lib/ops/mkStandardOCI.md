### `mkStandardOCI`

... is a function interface into the [third layer of packaging][packaging-third] of the Standard SDLC Packaging pattern.

It produces a Standard OCI Image from an ["operable"][operable].

The function signature is as follows:

```nix
{{#include ../../cells/lib/ops/mkStandardOCI.nix:9:27}}
```

#### The Standard Image

Standard images are minimal and hardened. They only contain required dependencies.

##### Contracts

The following contracts can be consumed:

```
/bin/entrypoint # always present
/bin/runtime    # always present, drops into the runtime environment
/bin/live       # if livenessProbe was set
/bin/ready      # if readinessProbe was set
```

That's it. There is nothing more to see.

All other dependencies are contained in `/nix/store/...`.

#### The Debug Image

Debug Images wrap the standard images and provide additional debugging packages.

Hence, they are neither minimal, nor hardened because of the debugging packages' added surface.

##### Contracts

The following contracts can be consumed:

```
/bin/entrypoint # always present
/bin/runtime    # always present, drops into the runtime environment
/bin/debug      # always present, drops into the debugging environment
/bin/live       # if livenessProbe was set
/bin/ready      # if readinessProbe was set
```

#### How to extend?

A Standard or Debug Image doesn't have a package manager available in the environment.

Hence, to extend the image you have two options:

##### Nix-based extension

```nix
rec {
  upstream = n2c.pullImage {
    imageName = "docker.io/my-upstream-image";
    imageDigest = "sha256:fffff.....";
    sha256 = "sha256-ffffff...";
  };
  modified = n2c.buildImage {
    name = "docker.io/my-modified-image";
    fromImage = upstream;
    contents = [nixpkgs.bashInteractive];
  };
}
```

##### Dockerfile-based extension

```Dockerfile
FROM alpine AS builder
RUN apk --no-cache curl

FROM docker.io/my-upstream-image
COPY --from=builder /... /

```

_Please refer to the official dockerfile documentation for more details._

[operable]: ./mkOperable.md
[packaging-third]: /patterns/four-packaging-layers.md#oci-image-layer
