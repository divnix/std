{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;
in
  /*
  Utility function to allow for building containers in a mono-repo style environment where
  the source code is contained in the same repository as the std code, specifically so that
  one may detect meaningful changes to the image via its tag in the special case where the
  package's output includes the revision of the source code (e.g. for displaying the version
  to the user).

  Without special processing, this kind of package would cause the OCI image tag to change
  on each new revision whether the actual contents of the image changed or not. Combined
  with `std.incl`, one may have a very strong indicator for when the contents of the image
  actually includes meaningful changes which avoids flooding the remote registry with superflous
  copies.

  This function can also be called where the package does not need the revsion at build time
  but you simply want to tag the image by its hash for later processing by the proviso, and
  you also want to include additional tags on the image, such as the revision.

  Args:
  args: arguments to the mkOCI function to be called.
  mkOCI: defaults to `mkStandardOCI`
  operable: The operable to include in the container
  ...: The same arguments expected by the given standard OCI builder

  Returns:
  An image tagged with the output hash of an identical image, except where the target package
  and operable are both built with the revision input set to "not-a-commit" instead of the true
  revision, so that the hash does not change unless something inside the image does.
  */
  args' @ {
    operable,
    mkOCI ? cell.ops.mkStandardOCI,
    ...
  }: let
    args = builtins.removeAttrs args' ["mkOCI"];
    revision = cell.ops.revise mkOCI args.operable (operable: args // {inherit operable;});
  in
    if args.operable ? sansrev
    then
      mkOCI (args
        // {
          meta =
            args.meta
            or {}
            // {
              tags = [revision.sansrev.outHash] ++ (args.meta.tags or []);
            };
        })
    else
      mkOCI (args
        // {
          meta =
            args.meta
            or {}
            // {
              tags = [(cell.ops.hashOfPath revision.outPath)] ++ (args.meta.tags or []);
            };
        })
