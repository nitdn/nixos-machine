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
  inherit (config.flake) wrappers packages;
in
{
  config.perSystem =
    {
      inputs',
      ...
    }:
    {
      packages.niri-unstable = inputs'.niri.packages.default;
    };
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
        package = packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        settings = {
          extraConfig = ''
            include "${./default_binds.kdl}"
            include "${./default_config.kdl}"
            include "${./window-rules.kdl}"
          '';
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
              accel-speed = 0.001;
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
          window-rule = [
            {
              geometry-corner-radius = 12;
              clip-to-geometry = true;
              tiled-state = true;
              draw-border-with-background = false;
            }
          ];

          outputs = {
            "Microstep MSI G244F BB4H113A00079" = {
              mode = "1920x1080";
              transform = "normal";
              variable-refresh-rate = _: { };
            };
          };
        };
      };
    };
  config.flake.modules.nixos = {
    pc =
      { pkgs, config, ... }:
      {
        fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
        services.displayManager.gdm.enable = true;
        programs.niri.enable = true;
        programs.niri.package = wrappers.niri-pc.wrap { inherit pkgs; };
        environment.systemPackages = lib.mkIf config.programs.niri.enable [
          pkgs.xwayland-satellite
          pkgs.adwaita-icon-theme
          pkgs.wayscriber
          pkgs.kdePackages.qt6ct
        ];
      };
  };
}
