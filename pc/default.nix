{
  inputs,
  lib,
  config,
  ...
}:
{
  options = {
    pc.username = lib.mkOption {
      type = lib.types.str;
    };
  };
  imports = [
    ./disko-elysium
    ./tjmaxxer
    ./phone-home
  ];
  config.flake.nixosModules.default =
    { pkgs, ... }:
    {
      imports = [
        ./configuration.nix
        ./stylix.nix
      ];
      programs.niri.enable = true;
      systemd.user.services.niri-flake-polkit.enable = false;
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      nixpkgs.overlays = [
        inputs.niri.overlays.niri
      ];
    };

  config.flake.homeModules = {
    default = {
      imports = [ ./home.nix ];
      home.username = config.pc.username;
    };
  };
}
