# SPDX-FileCopyrightText: 2022 David Arnold <dgx.arnold@gmail.com>
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{
  description = "Standard plugin for creating templates";
  # inputs.std.url = "github.com:divnix/std?ref=main";
  inputs.std.url = "../..";
  outputs =
    { std
    , ...
    }
    @ inputs:
    std.grow
      {
        inherit inputs;
        cellsFrom = ./src;
      };
}
