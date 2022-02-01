# SPDX-FileCopyrightText: 2022 The Standard Authors
# SPDX-FileCopyrightText: 2022 Kevin Amado <kamadorueda@gmail.com>
#
# SPDX-License-Identifier: Unlicense
{ inputs
, ...
}:
{
  build =
    { destination ? ""
    , executable ? false
    , name
    , meta ? { }
    , placeholders ? { }
    , src
    }:
    let
      escape = inputs.nixpkgs.lib.strings.escapeShellArg;
    in
      inputs.nixpkgs.stdenv.mkDerivation
        {
          builder = ./builder.sh;
          inherit meta;
          inherit name;
          envDestination = destination;
          envExecutable = executable;
          inherit src;
          envSubstituteArgs =
            inputs.nixpkgs.lib.strings.escapeShellArgs
              (
                builtins.concatLists
                  (
                    builtins.attrValues
                      (builtins.mapAttrs (placeholder: value: [ "--subst-var-by" placeholder value ]) (placeholders))
                  )
              );
        };
}
