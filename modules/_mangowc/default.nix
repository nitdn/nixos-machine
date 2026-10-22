# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.wrappers.mango-pc = { wlib, pkgs, ... }: {
    imports = [ wlib.wrapperModules.mangowc ];
    package = pkgs.mango;
  };
}
