# SPDX-FileCopyrightText: 2022 David Arnold <dgx.arnold@gmail.com>
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense

{ inputs
, system
}:
{
  testDefault =
    inputs.self.library.${ system.build.system }.create-build
      {
        name = "default";
        placeholders = {
          bool = true;
          int = 123;
          str = "s t r";
        };
        src =
          builtins.toFile
            "src"
            ''
              bool: @bool@
              int: @int@
              str: @str@
            '';
      };
}
