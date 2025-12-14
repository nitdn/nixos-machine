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
  flake.modules.nixos.dms =
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
      ''include "${./niri.kdl}"''
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
      systemd.tmpfiles.settings."10-dms" = {
        "/home/${user}/.cache/wal/colors.json"."L" = {
          inherit user;
          argument = "/home/${user}/.cache/wal/dank-pywalfox.json";
        };
      };
    };

}
