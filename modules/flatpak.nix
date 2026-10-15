# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ inputs, ... }:
{
  flake.modules.nixos.pc = { pkgs, ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
    services.flatpak.enable = true;
    environment.systemPackages = [ pkgs.gnome-software ];
    services.flatpak.packages = [
      "cn.wps.wps_365"
      "org.libreoffice.LibreOffice"
    ];
    services.flatpak.update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };
  };
}
