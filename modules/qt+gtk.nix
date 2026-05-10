# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  # This adds all the packages in the environment
  # required to get uniform look on themes
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        # fallback
        pkgs.hicolor-icon-theme

        # gtk
        pkgs.nwg-look
        pkgs.adw-gtk3
        pkgs.adwaita-icon-theme

        # qt6
        pkgs.kdePackages.qt6ct
        pkgs.kdePackages.breeze-icons
        pkgs.kdePackages.breeze
        pkgs.kdePackages.plasma-integration

      ];
    };
}
