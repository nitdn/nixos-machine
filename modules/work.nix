# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ moduleWithSystem, ... }:
{
  meta.unfreeNames = [
    "corefonts"
  ];
  flake.modules.nixos.pc = moduleWithSystem (
    { inputs', ... }:
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = [
        pkgs.onlyoffice-desktopeditors
        pkgs.libreoffice-qt6-fresh
        pkgs.hunspell
        pkgs.hunspellDicts.en-gb-large
        pkgs.logseq
        inputs'.affinity-nix.packages.v3
        (pkgs.writeShellApplication {
          name = "affinity-fix";
          runtimeInputs = [ inputs'.affinity-nix.packages.v3 ];
          text = ''
            affinity-v3 || affinity-v3
          '';
        })
        (
          let
            item = {
              name = "affinity-fix";
              desktopName = "Affinity (workaround for plugin-loader crash)";
              icon = "affinity-v3";
              exec = item.name;
            };
          in
          pkgs.makeDesktopItem item
        )
      ];
      i18n.inputMethod = {
        enable = true;
        # type = "ibus";
        # ibus.engines = [
        #   pkgs.ibus-engines.typing-booster
        #   pkgs.ibus-engines.openbangla-keyboard
        # ];

        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = [
          pkgs.catppuccin-fcitx5
          pkgs.fcitx5-gtk
          pkgs.fcitx5-openbangla-keyboard
        ];
      };
      fonts.packages = [
        pkgs.corefonts
      ];
      systemd.user.tmpfiles.rules =
        lib.lists.forEach
          [
            pkgs.corefonts
            pkgs.noto-fonts
            pkgs.noto-fonts-color-emoji
            pkgs.winePackages.fonts
          ]
          (pkg: ''
            C+ %h/.local/share/fonts/${pkg.pname} 0755 - - - ${pkg}/share/fonts/
            z %h/.local/share/fonts/${pkg.pname}/* 0755 - - -
          '');
    }
  );
}
