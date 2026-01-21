# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
      };
      environment.systemPackages = [ pkgs.keepassxc ];
    };
}
