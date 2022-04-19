# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
{
  inputs,
  cell,
}: let
  nixpkgs = inputs.nixpkgs;
in {
  default = let
    commit = inputs.self.shortRev or "dirty";
    date = inputs.self.lastModifiedDate or inputs.self.lastModified or "19700101";
    version = "0.1.0+${builtins.substring 0 8 date}.${commit}";
  in
    nixpkgs.buildGoModule rec {
      inherit version;
      pname = "std";
      meta.description = "A tui for projects that conform to Standard";

      src = ./cli;

      vendorSha256 = null;

      ldflags = [
        "-s"
        "-w"
        "-X main.buildVersion=${version}"
        "-X main.buildCommit=${commit}"
      ];
    };
}
