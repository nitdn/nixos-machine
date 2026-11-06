# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_:
let
  affinity = { unstablePkgs, ... }: {
    nix.settings = {
      extra-substituters = [ "https://cache.forall.systems" ];
      extra-trusted-public-keys = [
        "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
      ];
    };
    environment.systemPackages = [ unstablePkgs.affinity-v3 ];
  };
  productivity =
    {
      pkgs,
      lib,
      config,
      unstablePkgs,
      ...
    }:
    let
      cfg = config.hardware.graphics;

    in
    lib.mkIf cfg.enable {
      programs.kdeconnect = {
        enable = true;
      };
      environment.systemPackages = [
        pkgs.naps2
        pkgs.hunspell
        pkgs.hunspellDicts.en-gb-large
        pkgs.zathura
        pkgs.mesa.opencl
        pkgs.wineWow64Packages.stagingFull
        pkgs.krita
        unstablePkgs.faugus-launcher
        # pkgs.affinity-v3
      ];
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = [
          pkgs.fcitx5-openbangla-keyboard
        ];
      };
      fonts.packages = [
        pkgs.corefonts
        pkgs.winePackages.fonts
      ];
    };
in
{
  flake.modules.nixos = {
    work.imports = [
      productivity
      affinity
    ];
    tjmaxxer = productivity;
  };
}
