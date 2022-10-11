# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Michael Fellinger <https://manveru.dev/>
#
# SPDX-License-Identifier: MIT
{nixpkgs}: let
  l = nixpkgs.lib // builtins;

  debug = false;
  pretty = l.generators.toPretty {};

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

  incl = src: allowedPaths: let
    src' = l.unsafeDiscardStringContext (toString src);
    normalizedPaths =
      l.map (
        path: let
          path' = l.unsafeDiscardStringContext (toString path);
        in
          if l.hasPrefix l.storeDir path'
          then path'
          else src' + "/${path'}"
      )
      allowedPaths;
    patterns =
      l.traceIf debug "allowedPaths: ${pretty normalizedPaths}"
      l.traceIf
      debug "src: \"${src'}\""
      mkInclusive
      normalizedPaths;
    filter =
      l.traceIf debug "patterns: ${pretty patterns}"
      isIncluded
      patterns;
  in
    l.cleanSourceWith {
      name = "incl";
      inherit src filter;
    };

  mkInclusive = paths:
    l.foldl' (
      sum: path: let
        parts = pathToParts path;
        parts' =
          l.traceIf debug "node for \"${path}\": ${pretty parts}"
          parts;
      in {
        tree = l.recursiveUpdate (l.setAttrByPath parts' true) sum.tree;
        prefixes = sum.prefixes ++ [path];
      }
    ) {
      tree = {};
      prefixes = [];
    }
    paths;

  pathToParts = path: (l.splitString "/" path);

  isIncluded = patterns: _path: _type: let
    parts =
      l.traceIf debug "candidate ${_type}: ${_path}"
      pathToParts
      (toString _path);
  in
    if _type == "directory"
    then # recurse into node ?
      let
        hit = l.hasAttrByPath parts patterns.tree;
      in
        l.traceIf (debug && hit) "recurse on node: ${pretty parts}" hit
    else if _type == "regular"
    then # add file ?
      l.any (
        pre: let
          hit = l.hasPrefix pre _path;
        in
          l.traceIf (debug && hit) "include on prefix: ${pre}" hit
      )
      patterns.prefixes
    else true;
in
  incl
