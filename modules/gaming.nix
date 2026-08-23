# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  ...
}:
{
  flake.modules.nixos = {
    pc =
      { pkgs, config, ... }:
      let
        cfg = config.programs.steam;
      in
      {
        boot.kernelModules = [ "ntsync" ];
        programs.gamescope = {
          enable = true;
          args = [
            "--rt"
            "-W"
            "1920"
            "-H"
            "1080"
            "-r"
            "165"
            "-o"
            "60"
            "-s"
            "0.5"
            # "-S"
            # "integer"
            # "-F"
            # "linear"
            # "--max-scale"
            # "2"
            "--borderless"
            # "--fullscreen"
            "--grab"
            "--adaptive-sync"
          ];

        };
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
          dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        };
        programs.steam.extraCompatPackages = [
          pkgs.proton-ge-bin
        ];
        programs.steam.package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          # extraArgs = "-system-composer";
        };
        programs.steam.extraPackages = with pkgs; [
          # (gamescope.overrideAttrs (_: {
          #   NIX_CFLAGS_COMPILE = [ "-fno-fast-math" ];
          # }))
          steamtinkerlaunch
          libXcursor
          libXi
          libXinerama
          libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib # Provides libstdc++.so.6
          libkrb5
          keyutils
          # Add other libraries as needed
        ];
        programs.gamemode.enable = true;
        services.sunshine = {
          enable = true;
          autoStart = true;
          openFirewall = true;
        };
        hardware.uinput.enable = true;
        programs.obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = [
            pkgs.obs-studio-plugins.wlrobs
            pkgs.obs-studio-plugins.obs-vkcapture
          ];
        };
        environment.systemPackages = lib.mkIf cfg.enable [
          pkgs.mangohud
          pkgs.easyeffects
          # pkgs.lutris
          pkgs.umu-launcher
          pkgs.concord-tui
          pkgs.arrpc

        ];
      };
    disko-elysium = _: {
      users.users.gaming = {
        isNormalUser = true;
        password = "gaming";
        extraGroups = [ "gamemode" ];
      };
    };
    tjmaxxer =
      { pkgs, ... }:
      {
        imports = [ inputs.steam-presence.nixosModules.steam-presence ];
        programs.steam = {
          presence = {
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
        sops.secrets.steam-web-apiKey = { };
        systemd.user.services.steam-presence = {
          serviceConfig = {
            ImportCredential = "steam-api-key";
            WorkingDirectory = lib.mkForce "-%h/.local/state/steam-presence";
          };
        };
      };
  };
}
