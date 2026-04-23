# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  perSystem =
    { pkgs, ... }:
    {
      packages.dms-snapshot = pkgs.writeShellApplication {
        name = "dms-snapshot";
        text = ''
          cp "$HOME"/.config/niri/dms/*.kdl "$HOME"/nixos-machine/modules/dms/niri/
        '';
      };
      niri.settings = {
        environment."QT_QPA_PLATFORMTHEME" = "qt6ct";
        layer-rule._children = [
          {
            match._props.namespace = "^quickshell$";
            place-within-backdrop = true;
          }
        ];
      };
      niri.includes = [
        "dms/colors.kdl"
        "dms/layout.kdl"
        "dms/alttab.kdl"
        "dms/binds.kdl"
        "dms/outputs.kdl"
        "dms/cursor.kdl"
        "dms/windowrules.kdl"
      ];
    };
}
