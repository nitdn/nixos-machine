{
  inputs,
  lib,
  config,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;
in
{
  options = {
    pc.username = lib.mkOption {
      type = lib.types.str;
    };
    pc.allowedPredicates = lib.mkOption {
      type = lib.types.anything;
    };
  };
  imports = [
    ./disko-elysium
    ./tjmaxxer
    ./phone-home
    ./configuration.nix
    ./home.nix
  ];
  config.flake.modules.nixos.default = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.stylix.nixosModules.stylix
      inputs.niri.nixosModules.niri
      nixosModules.base
      nixosModules.niri
    ];
  };
  config.flake.modules.nixos.niri =
    { pkgs, ... }:
    {
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
}
