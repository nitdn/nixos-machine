# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  lib,
  ...
}:
let
  inherit (config.meta) username;
  inherit (config.flake) nvfetcher;
  dms =
    { pkgs, config, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      inherit (nvfetcher.${system}) dms-plugins;
      quickshell-src = nvfetcher.${system}.quickshell.src;
      quickshell = pkgs.callPackage quickshell-src { };

      cfg = config.programs.dms-shell;
    in
    {
      programs.dms-shell = {
        enable = true;
        quickshell.package = quickshell;
        systemd = {
          enable = true;
          restartIfChanged = true;
        };
        enableSystemMonitoring = true;
        enableVPN = true;
        enableDynamicTheming = true;
        enableAudioWavelength = true;
        enableCalendarEvents = true;
        plugins =
          lib.genAttrs
            [
              "DankKDEConnect"
              "DankLauncherKeys"
              "emojiLauncher"
            ]
            (name: {
              src = "${dms-plugins.src}/${name}";
            });
      };
      programs.dsearch.enable = true;
      services.displayManager.gdm.enable = false;
      systemd.user.services.dms.serviceConfig.Environment = [
        ''"QT_QPA_PLATFORMTHEME=qt6ct"''
      ];
      services.displayManager.dms-greeter = {
        enable = true;
        quickshell.package = quickshell;
        compositor = {
          name = "niri"; # Or "hyprland" or "sway"
          customConfig = ''
            output "DP-2" {
                mode "1920x1080@165.001"
                scale 1
                position x=0 y=0
            }
            hotkey-overlay {
              skip-at-startup
            }
          '';
        };
        # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
        configHome = "/home/${username}";
      };
      hardware.i2c.enable = true;
      programs.kdeconnect = {
        enable = true;
        package = pkgs.valent;
      };
      environment.systemPackages = lib.mkIf cfg.enable [
        pkgs.qt6Packages.qt6ct
        pkgs.adw-gtk3
      ];
    };
in
{
  flake = {
    modules.nixos = {
      inherit dms;
      pc = {
        imports = [
          config.flake.modules.nixos.dms
        ];
      };
    };
  };
}
