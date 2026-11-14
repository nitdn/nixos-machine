# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This is a homelab skeleton, please look at modules to see
# what the homelabs actually use

{ config, ... }:
let
  module = config.flake.modules.nixos.homelab;
in
{
  flake.modules.nixos.homelab = { };
  flake.modules.nixos = {
    disko-elysium.imports = [ module ];
  };
}
