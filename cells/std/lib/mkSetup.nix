{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  l = nixpkgs.lib // builtins;
in
  /*
  Creates a new setup task for configuring a container.

  Args:
    name: A name for the task.
    perms: A list of permissions to set for this task.
    contents: The contents of the setup task. This is a bash script.

  Returns:
    A setup task.
  */
  name: perms: contents: let
    setup = nixpkgs.runCommandNoCC "oci-setup-${name}" {} contents;
    perms' = l.map (p: p // { path = setup; }) perms;
  in
    setup
    // l.optionalAttrs (perms != []) { passthru.perms = perms'; }
