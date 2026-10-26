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
    meta = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.str;
      };
    };
  };
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.wrappers.flakeModules.wrappers
  ];

  config.meta.username = "ssmvabaa";
}
