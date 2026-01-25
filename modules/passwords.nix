# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.keepassxc ];
    };
  flake.modules.homeManager.pc = {
    services.syncthing.enable = true;
  };
}
