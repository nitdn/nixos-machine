# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.types) attrsOf anything;
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    options.nvfetched = lib.mkOption {
      type = attrsOf anything;
    };
  });
  config.perSystem =
    { pkgs, ... }:
    {
      nvfetched = pkgs.callPackage ../../_sources/generated.nix { };
    };
}
