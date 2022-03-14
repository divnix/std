# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Michael Fellinger <https://manveru.dev/>
#
# SPDX-License-Identifier: MIT
{nixpkgs}: let
  inherit (nixpkgs) lib;

  # NOTE: find a way to handle duplicates better, atm they may override each
  # other without warning
  mkInclusive = verifiedPaths:
    lib.foldl' (
      sum: verified: let
        verified' = builtins.unsafeDiscardStringContext verified;
      in
        if (lib.pathIsDirectory verified')
        then {
          tree = lib.recursiveUpdate sum.tree (lib.setAttrByPath (pathToParts verified') true);
          prefixes = sum.prefixes ++ [verified'];
        }
        else {
          tree = lib.recursiveUpdate sum.tree (lib.setAttrByPath (pathToParts verified') false);
          prefixes = sum.prefixes;
        }
    ) {
      tree = {};
      prefixes = [];
    }
    verifiedPaths;

  pathToParts = path: (builtins.tail (lib.splitString "/" (toString path)));

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
      builtins.map (
        path:
          builtins.path {
            name = "verify";
            path = path;
          }
      )
      paths;
  in
    builtins.deepSeq validation paths;

  isIncluded = patterns: name: type: let
    parts = pathToParts name;
    matchesTree = lib.hasAttrByPath parts patterns.tree;
    matchesPrefix = lib.any (pre: lib.hasPrefix pre name) patterns.prefixes;
  in
    matchesTree || matchesPrefix;

  incl = root: allowedPaths: let
    verifiedPaths = requireAllPathsExist allowedPaths;
    patterns = mkInclusive verifiedPaths;
    filter = isIncluded patterns;
  in
    builtins.path {
      name = "incl";
      path = root;
      filter = filter;
    };
in
  incl
