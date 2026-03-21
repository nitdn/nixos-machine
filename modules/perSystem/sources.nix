# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.types)
    attrsOf
    ;
  inherit (flake-parts-lib) mkTransposedPerSystemModule;
in
mkTransposedPerSystemModule {
  name = "nvfetcher";
  option = lib.mkOption {
    type = attrsOf lib.types.anything;
  };
  file = ./sources.nix;
}
