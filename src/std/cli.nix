# SPDX-FileCopyrightText: 2022 The Standard Authors
let
  version = nixpkgs.lib.fileContents (inputs.self + /VERSION);

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

    vendorHash = "sha256-ja0nFWdWqieq8m6cSKAhE1ibeN0fODDCC837jw0eCnE=";

    nativeBuildInputs = [nixpkgs.installShellFiles];

    postInstall = ''
      mv $out/bin/paisano $out/bin/${pname}

      installShellCompletion --cmd ${pname} \
        --bash <($out/bin/${pname} _carapace bash) \
        --fish <($out/bin/${pname} _carapace fish) \
        --zsh <($out/bin/${pname} _carapace zsh)
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
