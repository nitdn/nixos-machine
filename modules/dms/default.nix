# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  lib,
  getSystem,
  ...
}:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.dms =
    { pkgs, ... }:
    let
      perSystem = getSystem pkgs.stdenv.hostPlatform.system;
      inherit (perSystem.nvfetched) dms-plugins matugen-themes;
      matugenThemes = "${matugen-themes.src}/templates";
      matugen.config = { };
      matugen.templates.helix = {
        input_path = "${matugenThemes}/helix.toml";
        output_path = "/home/${username}/.config/helix/themes/matugen.toml";
      };
      matugen.templates.zathura = {
        input_path = "${matugenThemes}/zathura-colors";
        output_path = "/home/${username}/.config/zathura/zathurarc";
      };
      matugenTemplate = (pkgs.formats.toml { }).generate "matugen/config.toml" matugen;
    in
    {
      houses.users = {
        ssmvabaa.files = [
          {
            type = "symlink";
            source = matugenTemplate;
            target = ".config/matugen/config.toml";
          }
        ];
      };
      programs.dms-shell = {
        enable = true;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };
        # Core features
        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)
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
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
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
      environment.systemPackages = [
        pkgs.qt6Packages.qt6ct
        pkgs.adw-gtk3
      ];
      systemd.user.tmpfiles.rules = [
        "L %C/wal/colors.json - - - - %C/wal/dank-pywalfox.json"
        "C+ %h/.config/niri/dms 0755 - - - ${./niri}"
        "z %h/.config/niri/dms/* 0644 - - - -"
      ];
    };
  perSystem =
    { pkgs, ... }:
    {
      # Provide this for building a binary cache through CI
      packages.quickshell-cached =
        inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

      packages.dms-snapshot = pkgs.writeShellApplication {
        name = "dms-snapshot";
        text = ''
          cp "$HOME"/.config/niri/dms/* "$HOME"/nixos-machine/modules/dms/niri/
          cp "$HOME"/.config/helix/themes/* "$HOME"/nixos-machine/modules/dms/helix/
        '';
      };
      niri.settings = {
        environment."QT_QPA_PLATFORMTHEME" = "qt6ct";
        layer-rule.match._props.namespace = "^quickshell$";
        layer-rule.place-within-backdrop = true;
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
      wrappers.helix.pc.extraFiles = [
        {
          name = "themes/matugen_dark.toml";
          file.path = ./helix/matugen_dark.toml;
        }
        {
          name = "themes/matugen_light.toml";
          file.path = ./helix/matugen_light.toml;
        }
      ];
      wrappers.helix.pc.settings.theme = "matugen_dark";
      wrappers.helix.work.settings.theme = lib.mkForce "matugen_light";
      wrappers.kitty.pc.extraSettings =
        lib.strings.concatMapStringsSep "\n" (dmsPath: "include /home/${username}/.config/kitty/${dmsPath}")
          [
            "dank-tabs.conf"
            "dank-theme.conf"
          ];
    };

  flake.modules.nixos.pc =
    { ... }:
    {
      imports = [
        config.flake.modules.nixos.dms
      ];
    };

}
