let
  l = inputs.nixpkgs.lib // builtins;
in
  /*
  Makes a simple wrapper for executing an operable's package with args.

  Args:
  package: The package to wrap.
  args: Optional arguments to pass to the package's binary
  bin: Optional name of the binary if it cannot be determined by getExe

  Returns:
  A bash script which executes the pacakages binary with the given args.
  */
  {
    package,
    args ? [],
    bin ? "",
  }: let
    # Cumulatively builds up arguments...
    args' = let
      attrsToStr = {
        set,
        prefix ? "",
        suffix ? "",
      }:
        builtins.concatStringsSep "\n" (
          l.mapAttrsToList (name: value: ''${prefix}"${name}" "${toString value}"${suffix}'') set
        );
    in
      if builtins.isAttrs args
      then
        attrsToStr {
          set = args;
          prefix = "args+=(";
          suffix = ")";
        }
      else builtins.concatStringsSep "\n" (map (arg: ''args+=(${
          if l.isList arg
          then toString (map (str: ''"${toString str}"'') arg)
          else if l.isAttrs arg
          then attrsToStr {set = arg;}
          else ''"${arg}"''
        })'') args);

    # Parse out only the binary name from getExe
    exe = builtins.unsafeDiscardStringContext (l.baseNameOf (l.getExe package));
    bin' =
      if bin == ""
      then exe
      else bin;
  in ''
    declare -a args
    ${args'}
    exec ${package}/bin/${bin'} "''${args[@]}"
  ''
