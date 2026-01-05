# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos.thunar =
    { pkgs, ... }:
    {
      programs = {
        thunar.enable = true;
        thunar.plugins = with pkgs; [
          thunar-archive-plugin
          thunar-volman
        ];
        xfconf.enable = true;
      };
      environment.systemPackages = [
        pkgs.xarchiver
      ];
      services.tumbler.enable = true;
      services.gvfs.enable = true;
    };
  flake.modules.nixos.pc.imports = [ nixosModules.thunar ];
}
