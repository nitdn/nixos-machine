{ config, inputs, ... }:
let
  user = config.meta.username;
in
{
  flake.modules.homeManager.pc =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      dms =
        cmd:
        [
          "dms"
          "ipc"
          "call"
        ]
        ++ (pkgs.lib.splitString " " cmd);

    in
    {
      imports = [
        inputs.dankMaterialShell.homeModules.dankMaterialShell.default
        inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
      ];
      programs.dankMaterialShell = {
        enable = true;
        niri = {
          enableKeybinds = true; # Automatic keybinding configuration
          enableSpawn = true; # Auto-start DMS with niri
        };
        default.settings = {
          theme = lib.mkDefault "cat-sapphire";
          dynamicTheming = true;
          # Add any other settings here
        };
      };
      programs.niri.settings.binds = with config.lib.niri.actions; {
        "Mod+Escape".action = spawn (dms "dash toggle overview");
      };
      programs.niri.settings.environment = {
        QT_QPA_PLATFORMTHEME = "qt6ct";
      };
      programs.ghostty.settings.config-file = "./config-dankcolors";

      programs.kitty.extraConfig = ''
        include dank-tabs.conf
        include dank-theme.conf
      '';

      programs.helix.settings.theme = lib.mkDefault "catppuccin_mocha";
    };
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      imports = [
        inputs.dankMaterialShell.nixosModules.greeter
      ];
      # FIXME: DMS polkit agent doesn't seem to work
      # systemd.user.services.niri-flake-polkit.enable = false;
      services.displayManager.gdm.enable = false;
      programs.dankMaterialShell.greeter = {
        enable = true;
        compositor.name = "niri"; # Or "hyprland" or "sway"
      };
      hardware.i2c.enable = true;
      environment.systemPackages = [
        pkgs.qt6Packages.qt6ct
        pkgs.adw-gtk3
        pkgs.pywalfox-native
      ];
      systemd.tmpfiles.settings."10-dms" = {
        "/home/${user}/.cache/wal/colors.json"."L" = {
          inherit user;
          argument = "/home/${user}/.cache/wal/dank-pywalfox.json";
        };
      };
    };

}
