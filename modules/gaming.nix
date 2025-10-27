{
  meta.unfreeNames = [
    "steam"
    "steam-unwrapped"
  ];
  flake.modules.nixos.pc = {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    programs.gamemode.enable = true;
  };

  flake.modules.homeManager.pc =
    { pkgs, ... }:
    {
      programs.lutris = {
        enable = true;
        extraPackages = with pkgs; [
          gamemode
          gamescope
          mangohud
          umu-launcher
          winetricks
        ];
      };
    };
}
