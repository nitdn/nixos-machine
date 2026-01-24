# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.pc =
    { pkgs, config, ... }:
    {
      services.syncthing = {
        enable = true;
        user = username;
        group = username;
        dataDir = "/home/${username}/";
        configDir = config.services.syncthing.dataDir + "/.local/state/syncthing";
      };
      environment.systemPackages = [ pkgs.keepassxc ];
    };
}
