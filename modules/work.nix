# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, inputs, ... }:
let
  inherit (config.flake) packages;
in
{
  meta.unfreeNames = [
    "corefonts"
  ];
  flake.modules.nixos.pc =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      cfg = config.hardware.graphics;
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [
          packages.${system}.naps2-wrapped
          inputs.affinity-nix.packages.${system}.v3
          inputs.zen-browser.packages.${system}.default
          pkgs.hunspell
          pkgs.hunspellDicts.en-gb-large
          pkgs.libreoffice-qt6-fresh
          pkgs.logseq
          pkgs.zathura
          pkgs.onlyoffice-desktopeditors
          (pkgs.writeShellApplication {
            name = "affinity-fix";
            runtimeInputs = [ inputs.affinity-nix.packages.${system}.v3 ];
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
      };
    };

}
