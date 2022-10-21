{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
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
    args ? {},
    bin ? "",
  }: let
    # Cumulatively builds up arguments: args+=(\"name\" \"value\")\n....
    args' = builtins.concatStringsSep "\n" (
      l.mapAttrsToList (name: value: "args+=(\"${name}\" \"${value}\")") args
    );

    # Parse out only the binary name from getExe
    exe = builtins.unsafeDiscardStringContext (l.baseNameOf (l.getExe package));
    bin' =
      if bin == ""
      then exe
      else bin;
  in ''
    args+=()
    ${args'}
    exec ${package}/bin/${bin'} "''${args[@]}"
  ''
