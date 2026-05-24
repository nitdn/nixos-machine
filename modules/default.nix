# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  lib,
  ...
}:
{
  options = {
    meta.username = lib.mkOption {
      type = lib.types.str;
    };
    meta.term = lib.mkOption {
      type = lib.types.str;
    };
    flake.sources = {
      modules = lib.mkOption {
        type = lib.types.anything;
      };
      raw = lib.mkOption {
        type = lib.types.anything;
      };
    };
  };
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.wrappers.flakeModules.wrappers
  ];

  config.meta.username = "ssmvabaa";
  config.flake.sources.raw = ../_sources/generated.nix;
}
