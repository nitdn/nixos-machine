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
  user = config.meta.username;
in
{
  flake.modules.nixos.dms =
    { pkgs, ... }:
    {
      programs.dms-shell = {
        enable = true;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        systemd = {
          enable = true; # Systemd service for auto-start
          restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
        };
        # Core features
        enableSystemMonitoring = true; # System monitoring widgets (dgop)
        enableClipboard = true; # Clipboard history manager
        enableVPN = true; # VPN management widget
        enableDynamicTheming = true; # Wallpaper-based theming (matugen)
        enableAudioWavelength = true; # Audio visualizer (cava)
        enableCalendarEvents = true; # Calendar integration (khal)
      };

    };
  flake.modules.homeManager.pc = {
    programs.kitty.extraConfig = ''
      include dank-tabs.conf
      include dank-theme.conf
    '';
  };
  perSystem =
    { pkgs, ... }:
    {
      # Provide this for building a binary cache through CI
      packages.quickshell-cached =
        inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;

      packages.niri-dms-snapshot = pkgs.writeShellApplication {
        name = "niri-dms-snapshot";
        text = ''cp "$HOME"/.config/niri/dms/* "$HOME"/nixos-machine/modules/dms/niri/'';
      };
      niri.settings = {
        environment."QT_QPA_PLATFORMTHEME" = "qt6ct";
        layer-rule.match._props.namespace = "^quickshell$";
        layer-rule.place-within-backdrop = true;
      };
      niri.includes = lib.lists.map (path: "/home/${user}/.config/niri/${path}") [
        "dms/colors.kdl"
        "dms/layout.kdl"
        "dms/alttab.kdl"
        "dms/binds.kdl"
      ];
    };

  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.nixos.dms
      ];
      services.displayManager.gdm.enable = false;
      services.displayManager.dms-greeter = {
        enable = true;
        quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
        compositor.name = "niri"; # Or "hyprland" or "sway"
        # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
        configHome = "/home/${user}";
      };
      hardware.i2c.enable = true;
      environment.systemPackages = [
        pkgs.qt6Packages.qt6ct
        pkgs.adw-gtk3
        pkgs.pywalfox-native
      ];
      systemd.user.tmpfiles.rules = [
        "L %C/wal/colors.json - - - - %C/wal/dank-pywalfox.json"
        "C+ %h/.config/niri/dms 0755 - - - ${./niri}"
        "z %h/.config/niri/dms/* 0644 - - - -"
      ];
    };

}
