# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
{
  flake.modules.nixos.netbird = {
    services.netbird.enable = true;
    services.netbird.useRoutingFeatures = "client";
  };

  flake.modules.nixos.vps.imports = [ config.flake.modules.nixos.netbird ];

  flake.modules.nixos.pc = {
    imports = [ config.flake.modules.nixos.netbird ];
    services.netbird.ui.enable = true;
  };
}
