# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ lib, ... }: {
  flake.modules.nixos.pc =
    {
      pkgs,
      config,
      ...
    }:
    {
      fonts.packages = lib.mkIf config.hardware.graphics.enable [
        pkgs.atkinson-hyperlegible-next
        pkgs.iosevka
        pkgs.nerd-fonts.symbols-only
        pkgs.noto-fonts
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
        pkgs.noto-fonts-color-emoji

      ];

      fonts.fontconfig.defaultFonts = lib.mkIf config.hardware.graphics.enable {
        sansSerif = [
          "Atkinson Hyperlegible Next"
          "Noto Sans"
        ];
        serif = [
          "Noto Serif"
        ];
        monospace = [
          "Iosevka Extended"
        ];
      };
    };
}
