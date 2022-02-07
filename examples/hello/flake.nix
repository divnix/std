# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  # inputs.std.url = "github.com:divnix/std?ref=main";
  inputs.std.url = "../..";
  outputs =
    { std
    , ...
    }
    @ inputs:
    std.grow {
      inherit inputs;
      cellsFrom = ./src;
      systems = [
        {
          build = "x86_64-unknown-linux-gnu";
          host = "x86_64-unknown-linux-gnu";
        }
        {
          build = "x86_64-unknown-linux-gnu";
          host = "i686-w64-mingw32";
        }
      ];
    };
}
