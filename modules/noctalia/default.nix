# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
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
  flake.wrappers = {
    noctalia-pc =
      { wlib, config, ... }:
      {
        imports = [
          wlib.wrapperModules.noctalia-shell
        ];
        inherit ((import ./settings.nixon)) settings;
        plugins = {
          sources = [
            {
              enabled = true;
              name = "Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            valent-connect = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 2;
        };
        outOfStoreConfig = lib.mkDefault "/tmp/noctalia-pc/";
        constructFiles.theme = {
          content = lib.readFile "${inputs.noctalia-colorschemes}/Everdeer/Everdeer.json";
          relPath = "${config.generatedConfigDirname}/colorschemes/Everdeer/Everdeer.json";
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
      { pkgs, ... }:
      let
        noctaliaExe = lib.getExe (wrappers.noctalia-pc.wrap { inherit pkgs; });
      in
      {
        extraConfigLines = ''
          include optional=true "~/.config/niri/noctalia.kdl"
        '';
        settings = {
          spawn-at-startup = [
            noctaliaExe
            [
              "valent"
              "--gapplication-service"
            ]
          ];
          binds."Mod+Space".spawn = [
            noctaliaExe
            "ipc"
            "call"
            "launcher"
            "toggle"
          ];

          layer-rules = [
            {
              matches = [ { namespace = "^noctalia-wallpaper*"; } ];
              place-within-backdrop = true;
            }
          ];

          layout = {
            background-color = "transparent";
          };

          overview = {
            workspace-shadow.off = _: { };
          };
        };
      };
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
  perSystem =
    { config, ... }:
    {
      niri.settings = {
        _children = [
          {
            spawn-at-startup = [
              (lib.getExe config.packages.noctalia-pc)
            ];
            # Set the regular wallpaper on the backdrop.
            layer-rule._children = [
              {
                match._props.namespace = "^noctalia-wallpaper*";
                place-within-backdrop = true;
              }
            ];
          }
        ];

        # Set transparent workspace background color so you see the backdrop at all times.
        layout = {
          background-color = "transparent";
        };

        # Optionally, disable the workspace shadows in the overview.
        overview = {
          workspace-shadow = {
            off = { };
          };
        };
      };
    };
}
