{ inputs, config, ... }:
let
  homeModules = config.flake.modules.homeManager;
in
{
  meta.unfreeNames = [
    "steam"
    "steam-unwrapped"
  ];
  flake.modules.nixos.pc =
    { pkgs, ... }:
    let
      partialWrapper = definition: inputs.wrappers.lib.wrapPackage (definition // { inherit pkgs; });
    in
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        package = pkgs.steam.override {
          extraEnv = {
            MANGOHUD = true;
            OBS_VKCAPTURE = true;
            RADV_TEX_ANISO = 16;
          };
          extraArgs = "-system-composer";
        };
      };
      programs.gamemode.enable = true;
      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        plugins = with (pkgs.obs-studio-plugins); [
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
      programs.niri.settings.binds = {
        "Mod+S".action.set-dynamic-cast-window = { };
      };
    };
}
