# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ lib, config, ... }:
let
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos.thunar =
    { pkgs, config, ... }:
    {
      programs = lib.mkIf config.hardware.graphics.enable {
        thunar.enable = true;
        thunar.plugins = [
          pkgs.thunar-archive-plugin
          pkgs.thunar-volman
        ];
        xfconf.enable = true;
      };
      environment.systemPackages = [
        pkgs.kdePackages.ark
      ];
      services.tumbler.enable = true;
      services.gvfs = {
        enable = true;
        package = pkgs.gnome.gvfs;
      };
    };
  flake.modules.nixos.pc.imports = [ nixosModules.thunar ];
}
