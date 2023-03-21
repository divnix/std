{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in
  /*
  For use with `revise` and `reviseOCI` to build containers in a mono-repo style
  environment where the source code is contained in the same repository as the std code,
  specifically so that one may detect meaningful changes to the image via its tag in the
  special case where the package's output includes the revision of the source code (e.g. for
  displaying the version to the user).

  Without special processing, this kind of package would cause the OCI image tag to change
  on each new revision whether the actual contents of the image changed or not. Combined
  with `std.incl`, one may have a very strong indicator for when the contents of the image
  actually includes meaningful changes which avoids flooding the remote registry with superflous
  copies.

  Args:
  target: Same as the first argument to upstream `callPackage`.
  args: Arguments to `callPackage`.

  Returns:
  The package with a clone of itself in the passthru where the expected revision is set to
  "not-a-commit" for later use by `revise` & `reviseOCI`.
  */
  target: args @ {
    rev,
    callPackage ? nixpkgs.callPackage,
    ...
  }: let
    pkg = callPackage target (builtins.removeAttrs args ["callPackage"]);
  in
    if pkg ? sansrev
    then pkg
    else cell.ops.revise (_: _) pkg (_: _)
