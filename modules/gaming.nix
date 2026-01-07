# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
in
{
  meta.unfreeNames = [
    "steam"
    "steam-unwrapped"
  ];
  flake.modules.nixos.pc =
    { pkgs, config, ... }:
    let
      partialWrapper = definition: inputs.wrappers.lib.wrapPackage (definition // { inherit pkgs; });
    in
    {
      imports = [ inputs.steam-presence.nixosModules.steam-presence ];

      sops.secrets.steam-web-apiKey = {
        mode = "0640";
        group = "users";
      };
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        package = pkgs.steam.override {
          extraEnv = {
            # MANGOHUD = true; maybe too dangerous to enable by default
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraArgs = "-system-composer";
        };
        presence = {
          enable = true;
          # Either set the key directly (not recommended) or via file/secret
          # steamApiKey = "YOUR_STEAM_WEB_API_KEY";
          steamApiKeyFile = config.sops.secrets.steam-web-apiKey.path; # e.g. from agenix/sops
          userIds = [ "76561198809805717" ];
          localGames = {
            enable = true;
            games = [
              ".kitty-wrapped"
              ".zen-beta-wrapped"
            ];
          };
          gamesFile = pkgs.writeText "games.txt" ''
            .kitty-wrapped=Kitty Terminal
            .zen=Zen Browser
          '';
          # Other optional settings
        };
      };
      systemd.user.tmpfiles.rules =
        let
          cfgDir = config.systemd.user.services.steam-presence.serviceConfig.WorkingDirectory;
        in
        [
          "d ${cfgDir} - - - - -"
        ];
      programs.gamemode.enable = true;
      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-vkcapture
        ];
      };
      environment.systemPackages = [
        (partialWrapper {
          exePath = "${pkgs.mangohud}/bin/mangohud";
          package = pkgs.mangohud;
          env.MANGOHUD_CONFIG = "no_display,fps_limit=165";
        })
      ];
    };
  flake.modules.nixos.disko-elysium = {
    users.users.gaming = {
      isNormalUser = true;
      password = "gaming";
    };
    home-manager.users."gaming" = homeModules.pc;
  };

  flake.modules.homeManager.pc =
    { pkgs, ... }:
    {
      # programs.mangohud.enable = true;
      # programs.mangohud.settings = {
      #   fps_limit = 165;
      #   no_display = true;
      # };
      programs.lutris = {
        enable = true;
        extraPackages = with pkgs; [
          gamemode
          gamescope
          umu-launcher
          winetricks
        ];
      };
    };
}
