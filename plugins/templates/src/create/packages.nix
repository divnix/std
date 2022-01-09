{ inputs
, system
}:
{
  testDefault = inputs.self.functions.${system.build.system}.create {
    name = "default";
    placeholders = {
      bool = true;
      int = 123;
      str = "s t r";
    };
    src = builtins.toFile "src" ''
      bool: @bool@
      int: @int@
      str: @str@
    '';
  };
}
