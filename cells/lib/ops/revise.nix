{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in
  /*
  For use with `revisePackage` and `reviseOCI` to build containers in a mono-repo style
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
  op: Optional function which takes the package as an argument.
  pkg: The package you wish to revise.
  fn: Optional functor with a reference to `pkg` if needed by `op`.

  Returns:
  The package with a clone of itself in the passthru where the expected revision is set to
  "not-a-commit" for later use by `reviseOCI`.
  */
  op: pkg: fn: let
    result = op (fn pkg);
    dummy = "not-a-commit";
    rev = pkg.src.rev or pkg.src.origSrc.rev or dummy;
  in
    if pkg ? sansrev || (rev != dummy && result == pkg)
    then
      result.overrideAttrs (_: {
        passthru =
          result.passthru
          or {}
          // {
            sansrev = let
              pkg' = op (fn (pkg.sansrev or (pkg.override {rev = dummy;})));
            in
              pkg'.overrideAttrs (_: {
                passthru =
                  pkg'.passthru
                  or {}
                  // {
                    outHash = cell.ops.hashOfPath pkg'.outPath;
                  };
              });
          };
      })
    else result
