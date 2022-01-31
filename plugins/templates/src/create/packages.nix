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
