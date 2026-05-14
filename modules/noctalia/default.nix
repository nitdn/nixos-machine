# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  # inputs,
  config,
  lib,
  ...
}:
let
  inherit (config.flake) wrappers;
in
{
  flake.wrappers = {
    noctalia-pc =
      { wlib, ... }:
      {
        # options.nativeStorePlugins = lib.mkOption {
        #   type = listOf str;
        #   description = "List of plugins that could be found in the noctalia plugin repo";
        #   default = [
        #     "polkit-agent"
        #     "mimeapp-gui"
        #     "kde-connect"
        #     "port-monitor"
        #   ];
        # };
        imports = [
          wlib.wrapperModules.noctalia-shell
        ];
        config = {
          inherit ((import ./_settings.nix)) settings;
          plugins = import ./_plugins.nix;

          # preInstalledPlugins = mkNativeStorePlugins cfg.nativeStorePlugins;
          outOfStoreConfig = lib.mkDefault "/tmp/noctalia-pc/";
        };
      };
    noctalia-light = {
      imports = [
        config.flake.wrapperModules.noctalia-pc
      ];
      outOfStoreConfig = "/tmp/noctalia-light/";
      settings.colorSchemes.darkMode = lib.mkForce false;
    };
    niri-pc =
      let
        noctaliaExe = "noctalia-shell";
      in
      {
        extraSettings = [
          {
            include = [
              { optional = true; }
              "~/.config/niri/noctalia.kdl"
            ];
          }
        ];
        settings = {
          spawn-at-startup = [
            noctaliaExe
            # [
            #   "valent"
            #   "--gapplication-service"
            # ]
          ];
          binds."Mod+Space" = _: {
            props = {
              hotkey-overlay-title = "Toggle launcher";
            };
            content.spawn = [
              noctaliaExe
              "ipc"
              "call"
              "launcher"
              "toggle"
            ];
          };
          binds."Mod+E" = _: {
            props = {
              hotkey-overlay-title = "Toggle Calendar/Clock";
            };
            content.spawn = [
              noctaliaExe
              "ipc"
              "call"
              "calendar"
              "toggle"
            ];
          };
          binds."Mod+Delete" = _: {
            props = {
              hotkey-overlay-title = "Toggle logout menu";
            };
            content.spawn = [
              noctaliaExe
              "ipc"
              "call"
              "sessionMenu"
              "toggle"
            ];
          };

          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-wallpaper*"; } ];
              place-within-backdrop = true;
            }
          ];

          debug = {
            honor-xdg-activation-with-invalid-serial = _: { };
          };

          layout = {
            background-color = "transparent";
          };

          overview = {
            workspace-shadow.off = _: { };
          };
        };
      };
    kitty-pc = {
      extraSettings.include = [ "~/.config/kitty/themes/noctalia.conf" ];
    };
  };
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.wtype
      ];
    };
  flake.modules.nixos.darkMode =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (wrappers.noctalia-pc.wrap { inherit pkgs; })
      ];
    };
  flake.modules.nixos.lightMode =
    { pkgs, ... }:
    {
      # We need this to do the ipc lol
      environment.systemPackages = [
        (wrappers.noctalia-light.wrap { inherit pkgs; })
      ];
    };
}
