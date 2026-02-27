# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.keepassxc ];
      systemd.packages = [ pkgs.syncthing ];
      systemd.user.services.syncthing = {
        after = [ "network.target" ];
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = username;
      };
    };
}
