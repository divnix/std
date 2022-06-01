# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Michael Fellinger <https://manveru.dev/>
#
# SPDX-License-Identifier: MIT
{nixpkgs}: let
  l = nixpkgs.lib // builtins;

  /*
  A source inclusion helper.

  With incl, you can specify what files should become part of the
  input hashing function of nix.

  That means, that only if that hash changes, a rebuild is triggered.

  By only including the sources that are an actual ingredient to your
  build process, you can greatly reduce the need for arbitrary builds.

  Slightly less effective than language native build caching. But hey,
  it's 100% polyglot.

  You can use this function independently of the rest of std.
  */

  incl = root: allowedPaths: let
    verifiedPaths = requireAllPathsExist allowedPaths;
    patterns = mkInclusive verifiedPaths;
    filter = isIncluded patterns;
  in
    l.path {
      name = "incl";
      path = root;
      filter = filter;
    };

  # NOTE: find a way to handle duplicates better, atm they may override each
  # other without warning
  mkInclusive = verifiedPaths:
    l.foldl' (
      sum: verified: let
        verified' = l.unsafeDiscardStringContext verified;
      in
        if (l.pathIsDirectory verified')
        then {
          tree = l.recursiveUpdate sum.tree (l.setAttrByPath (pathToParts verified') true);
          prefixes = sum.prefixes ++ [verified'];
        }
        else {
          tree = l.recursiveUpdate sum.tree (l.setAttrByPath (pathToParts verified') false);
          prefixes = sum.prefixes;
        }
    ) {
      tree = {};
      prefixes = [];
    }
    verifiedPaths;

  pathToParts = path: (l.tail (l.splitString "/" (toString path)));

  # Require that every path specified does exist.
  #
  # By default, Nix won't complain if you refer to a missing file
  # if you don't actually use it:
  #
  #     nix-repl> ./bogus
  #     /home/grahamc/playground/bogus
  #
  #     nix-repl> toString ./bogus
  #     "/home/grahamc/playground/bogus"
  #
  # so in order for this interface to be *exact*, we must
  # specifically require every provided path exists:
  #
  #     nix-repl> "${./bogus}"
  #     error: getting attributes of path
  #     '/home/grahamc/playground/bogus': No such file or
  #     directory
  requireAllPathsExist = paths: let
    validation =
      l.map (
        path:
          l.path {
            name = "verify";
            path = path;
          }
      )
      paths;
  in
    l.deepSeq validation paths;

  isIncluded = patterns: name: type: let
    parts = pathToParts name;
    matchesTree = l.hasAttrByPath parts patterns.tree;
    matchesPrefix = l.any (pre: l.hasPrefix pre name) patterns.prefixes;
  in
    matchesTree || matchesPrefix;
in
  incl
