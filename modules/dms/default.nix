{
  config,
  inputs,
  lib,
  ...
}:
let
  user = config.meta.username;
in
{
  flake.modules.nixos.dms = {
    imports = [
      inputs.dankMaterialShell.nixosModules.dankMaterialShell
    ];
    programs.dankMaterialShell = {
      enable = true;
    };

  };
  flake.modules.homeManager.pc = {
    programs.kitty.extraConfig = ''
      include dank-tabs.conf
      include dank-theme.conf
    '';
  };

  perSystem.niri.extraConfig = lib.strings.concatLines (
    [
      ''spawn-at-startup "dms" "run"''
      ''
        environment {
            "QT_QPA_PLATFORMTHEME" "qt6ct"
        }
      ''
    ]
    ++ lib.lists.map (path: "include \"/home/${user}/.config/niri/${path}\"") [
      "dms/colors.kdl"
      "dms/layout.kdl"
      "dms/alttab.kdl"
      "dms/binds.kdl"
    ]
  );

  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      imports = [
        inputs.dankMaterialShell.nixosModules.greeter
        config.flake.modules.nixos.dms
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
      systemd.user.tmpfiles.rules = [
        "L %C/wal/colors.json - - - - %C/wal/dank-pywalfox.json"
        "C+ %h/.config/niri/dms 0755 - - - ${./niri}"
        "z %h/.config/niri/dms/* 0644 - - - -"
      ];
    };

}
