# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config.flake.wrappers.niri-pc =
    { pkgs, lib, ... }:
    {
      settings = {
        binds = {
          "XF86AudioRaiseVolume" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Raise Volume";
            };
            content.spawn = [
              (lib.getExe' pkgs.wireplumber "wpctl")
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "0.1+"
              "-l"
              "1.0"
            ];
          };
          "XF86AudioLowerVolume" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Lower Volume";
            };
            content.spawn = [
              (lib.getExe' pkgs.wireplumber "wpctl")
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "0.1-"
            ];
          };
          "XF86AudioMute" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Mute Output";
            };
            content.spawn = [
              (lib.getExe' pkgs.wireplumber "wpctl")
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
          };
          "XF86AudioMicMute" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Mute Microphone";
            };
            content.spawn = [
              (lib.getExe' pkgs.wireplumber "wpctl")
              "set-mute"
              "@DEFAULT_AUDIO_SOURCE@"
              "toggle"
            ];
          };
          "XF86AudioPlay" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Play / Pause";
            };
            content.spawn = [
              (lib.getExe pkgs.playerctl)
              "play-pause"
            ];
          };
          "XF86AudioStop" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Stop Playback";
            };
            content.spawn = [
              (lib.getExe pkgs.playerctl)
              "stop"
            ];
          };
          "XF86AudioPrev" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Previous Track";
            };
            content.spawn = [
              (lib.getExe pkgs.playerctl)
              "previous"
            ];
          };
          "XF86AudioNext" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Next Track";
            };
            content.spawn = [
              (lib.getExe pkgs.playerctl)
              "next"
            ];
          };
          "XF86MonBrightnessUp" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Increase Brightness";
            };
            content.spawn = [
              (lib.getExe pkgs.brightnessctl)
              "--class=backlight"
              "set"
              "+10%"
            ];
          };
          "XF86MonBrightnessDown" = _: {
            props = {
              allow-when-locked = true;
              hotkey-overlay-title = "Decrease Brightness";
            };
            content.spawn = [
              (lib.getExe pkgs.brightnessctl)
              "--class=backlight"
              "set"
              "10%-"
            ];
          };
        };
      };
    };
}
