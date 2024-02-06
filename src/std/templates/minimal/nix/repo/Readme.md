## Contributing

### Prerequisites

You need [nix](https://nixos.org/download.html) and [direnv](https://direnv.net/).

### Enter Contribution Environment

```console
direnv allow
```

### Change Contribution Environment

```console
$EDITOR ./nix/repo/configs.nix
direnv reload
```

### Preview Documentation

<sub>You need to be inside the Contribution Environment.</sub>

```console
mdbook build -o
```
