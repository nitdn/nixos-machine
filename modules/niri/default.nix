# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (config.flake) wrappers;
in
{
  config.flake.wrappers.niri-pc =
    {
      wlib,
      pkgs,
      ...
    }:
    {
      imports = [
        wlib.wrapperModules.niri
      ];
      config = {
        extraSettings = [
          { include = ./default_config.kdl; }
          { include = ./window-rules.kdl; }
        ];
        settings = {
          spawn-at-startup = [
            (lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
          ];
          environment = {
            QT_QPA_PLATFORMTHEME = "qt6ct";
          };
          input = {
            keyboard = {
              xkb.options = "compose:caps";
            };
            mouse = {
              accel-profile = "flat";
              accel-speed = -0.8;
            };
          };
          layout = {
            gaps = 4;
            border = {
              width = 2;
            };
            focus-ring = {
              width = 2;
            };
          };
          window-rules = [
            {
              geometry-corner-radius = 20;
              clip-to-geometry = true;
              opacity = 0.8;
              draw-border-with-background = false;
              background-effect = {
                blur = true;
              };
            }
          ];
          outputs = {
            "Microstep MSI G244F BB4H113A00079" = {
              mode = "1920x1080";
              transform = "normal";
              # Its bugging again
              # variable-refresh-rate = _: { };
            };
          };
        };
      };
    };
  config.flake.modules.nixos = {
    pc =
      { pkgs, config, ... }:
      let
        niriPkg = wrappers.niri-pc.wrap { inherit pkgs; };
      in
      {
        fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
        programs.niri.enable = true;
        programs.niri.package = niriPkg;
        environment.systemPackages = lib.mkIf config.programs.niri.enable [
          pkgs.xwayland-satellite
          pkgs.adwaita-icon-theme
          pkgs.wayscriber
          pkgs.kdePackages.qt6ct
        ];
      };
  };
}
