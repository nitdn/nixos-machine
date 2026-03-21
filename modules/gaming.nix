# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (config.meta) username;
  dummySystem = "x86_64-linux"; # dummy value as the fetcher doesnt really care
  inherit (config.flake.nvfetcher.${dummySystem}) steam-presence;
in
{
  flake.modules.nixos = {
    pc =
      { pkgs, config, ... }:
      let
        cfg = config.programs.steam;
        partialWrapper = definition: inputs.wrappers.lib.wrapPackage (definition // { inherit pkgs; });
      in
      {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
          dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        };
        programs.steam.package = lib.mkDefault (
          pkgs.steam.override {
            extraEnv = {
              MANGOHUD = true;
              OBS_VKCAPTURE = true;
              RADV_TEX_ANISO = 16;
            };
          }
        );
        programs.gamemode.enable = true;
        programs.obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = [
            pkgs.obs-studio-plugins.wlrobs
            pkgs.obs-studio-plugins.obs-vkcapture
          ];
        };
        environment.systemPackages = lib.mkIf cfg.enable [
          (partialWrapper {
            exePath = "${pkgs.mangohud}/bin/mangohud";
            package = pkgs.mangohud;
            env.MANGOHUD_CONFIG = "no_display,fps_limit=165";
          })
          pkgs.gamemode
          pkgs.gamescope
          pkgs.lutris
          pkgs.umu-launcher
          pkgs.vesktop
          pkgs.wineWow64Packages.stagingFull
          pkgs.winetricks
        ];
      };
    disko-elysium =
      {
        pkgs,
        ...
      }:
      {
        users.users.gaming = {
          isNormalUser = true;
          password = "gaming";
        };
        programs.steam.package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraArgs = "-system-composer";
        };
      };
    tjmaxxer =
      { pkgs, config, ... }:
      {
        imports = [ "${steam-presence.src}/nix/nixos-modules/steam-presence.nix" ];

        programs.steam.package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraArgs = "-system-composer";
        };
        sops.secrets.steam-web-apiKey = {
          owner = username;
        };
        systemd.user.services.steam-presence = {
          serviceConfig = {
            LoadCredential = "steam-api-key:${config.sops.secrets.steam-web-apiKey.path}";
            WorkingDirectory = lib.mkForce "-%h/.local/state/steam-presence";
          };
        };
        programs.steam.presence = {
          enable = true;
          # Either set the key directly (not recommended) or via file/secret
          # steamApiKey = "YOUR_STEAM_WEB_API_KEY";
          steamApiKeyFile = "/%d/steam-api-key"; # e.g. from agenix/sops
          userIds = [ "76561198809805717" ];
          localGames = {
            enable = true;
            games = [
              ".kitty-wrapped"
              ".zen"
            ];
          };
          gamesFile = pkgs.writeText "games.txt" ''
            .kitty-wrapped=Kitty Terminal
            .zen=Zen Browser
          '';
          # Other optional settings
        };
      };
  };
}
