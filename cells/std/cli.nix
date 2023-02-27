# SPDX-FileCopyrightText: 2022 The Standard Authors
let
  version = "0.15.0+dev";

  inherit (inputs) nixpkgs;
  inherit (nixpkgs.lib) licenses;
in {
  default = cell.cli.std;

  std = nixpkgs.buildGoModule rec {
    inherit version;
    pname = "std";
    meta = {
      inherit (import (inputs.self + /flake.nix)) description;
      license = licenses.unlicense;
      homepage = "https://github.com/divnix/std";
    };

    src = inputs.paisano-tui.sourceInfo + /src;

    vendorHash = "sha256-1le14dcr2b8TDUNdhIFbZGX3khQoCcEZRH86eqlZaQE=";

    nativeBuildInputs = [nixpkgs.installShellFiles];

    postInstall = ''
      mv $out/bin/paisano $out/bin/${pname}

      installShellCompletion --cmd std \
        --bash <($out/bin/std _carapace bash) \
        --fish <($out/bin/std _carapace fish) \
        --zsh <($out/bin/std _carapace zsh)
    '';

    ldflags = [
      "-s"
      "-w"
      "-X main.buildVersion=${version}"
      "-X main.argv0=${pname}"
      "-X main.project=Standard"
      "-X flake.registry=__std"
      "-X env.dotdir=.std"
    ];
  };
}
