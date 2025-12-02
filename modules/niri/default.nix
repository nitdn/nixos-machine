{ inputs, config, ... }:
let
  inherit (config.meta) term;
in
{
  flake.modules.homeManager.pc =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nautilus
        xwayland-satellite
        wl-clipboard
        libnotify
        brightnessctl
      ];

      programs.niri.settings.layout.gaps = 5;
      programs.niri.settings.prefer-no-csd = true;
      programs.niri.settings.outputs.DP-2 = {
        # variable-refresh-rate = true;
        mode = {
          height = 1080;
          width = 1920;
        };
      };
      programs.niri.settings.spawn-at-startup = [
        {
          command = [
            "ckb-next"
            "--background"
          ];
        }
        { command = [ term ]; }
        { command = [ "zen-beta" ]; }
        { command = [ "obsidian" ]; }
        { command = [ "vesktop" ]; }
        # { command = [ "waybar" ]; }
      ];
      programs.niri.settings.environment = {
        DISPLAY = ":0";
      };

      programs.niri.settings.input.mouse = {
        accel-profile = "flat";
        accel-speed = -0.7;
      };
      programs.niri.settings.animations.workspace-switch.kind.spring = {
        damping-ratio = 1.0;
        epsilon = 0.0001;
        stiffness = 1000;
      };
    };
  flake.modules.homeManager.standalone =
    { pkgs, config, ... }:
    {
      imports = [
        inputs.niri.homeModules.niri
        # inputs.niri.homeModules.stylix
      ];
      nixpkgs.overlays = [
        inputs.niri.overlays.niri
      ];
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri-unstable;
    };
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      imports = [
        inputs.niri.nixosModules.niri
      ];
      nixpkgs.overlays = [
        inputs.niri.overlays.niri
      ];
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri-unstable;
      # systemd.user.services.niri-flake-polkit.enable = false;
      # systemd.user.services.polkit-gnome-authentication-agent-1 = {
      #   description = "polkit-gnome-authentication-agent-1";
      #   wantedBy = [ "graphical-session.target" ];
      #   wants = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig = {
      #     Type = "simple";
      #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      #     Restart = "on-failure";
      #     RestartSec = 1;
      #     TimeoutStopSec = 10;
      # };
      # };
    };
}
