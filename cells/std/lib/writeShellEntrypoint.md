# `writeShellEntrypoint`

... is a function to write Standard OCI-image entrypoints.

The function signature is as follows:

```nix
{
  # the installable that is wrapped by this entrypoint (re-exported)
  package,
  # the literal bash string of the entrypoint that will be wrapped
  entrypoint,
  # initialize environment variables with these defaults
  env ? {},
  # runtime installables that the entrypoint or liveness/readiness probe uses (re-exported)
  runtimeInputs ? [],
  # domain specific debugging utilities (re-exported)
  debugInputs ? [],
  # domain specific liveness probe literal bash fragment (re-exported)
  livenessProbe ? null,
  # domain specific readiness probe literal bash fragment (re-exported)
  readinessProbe ? null,
}
```

It's output wraps utility functions to generate size-optimized OCI-images:

```nix
rec {
  entrypoint = std.std.lib.writeShellEntrypoint inputs { /* ... */ };
  oci-image = entrypoint.mkOCI "docker.io/my-oci-image";
  oci-debug-image = entrypoint.mkDebugOCI "docker.io/my-oci-image-debug";
}
```

## The Standard Image

Standard images are minimal and hardened. They only contain required dependencies.

### Contracts

The following contracts can be consumed:

```
/bin/entrypoint # always present
/bin/live       # if livenessProbe was set
/bin/ready      # if readinessProbe was set
```

That's it. There is nothing more to see.

All other dependencies are contained in `/nix/store/...`.

## The Debug Image

Debug Images wrap the standard images and provide additional debugging packages.

Hence, they are neither minimal, nor hardened because of the debugging packages' added surface.

### Contracts

The following contracts can be consumed:

```
/bin/entrypoint # always present
/bin/debug      # always present, drops into the debugging environment
/bin/live       # if livenessProbe was set
/bin/ready      # if readinessProbe was set
```

## How to extend?

A Standard or Debug Image doesn't have a package manager available in the environment.

Hence, to extend the image you have two options:

### Nix-based extension

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

### Dockerfile-based extension

```Dockerfile
FROM alpine AS builder
RUN apk --no-cache curl

FROM docker.io/my-upstream-image
COPY --from=builder /... /

```

_Please refer to the official dockerfile documentation for more details._
