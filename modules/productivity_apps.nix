# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_:
let
  productivity =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.hardware.graphics;

      # Nixpkgs makes some truly degenerate ibus desktop entries
      killIbusAutostart = pkgs.writeTextFile {
        name = "kill-autostart-ibus-daemon";
        destination = "/etc/xdg/autostart/ibus-daemon.desktop";
        text = "";
      };
    in
    lib.mkIf cfg.enable {
      # nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];
      programs.kdeconnect = {
        enable = true;
      };
      environment.systemPackages = [
        (lib.mkForce killIbusAutostart)
        pkgs.naps2
        pkgs.hunspell
        pkgs.hunspellDicts.en-gb-large
        pkgs.libreoffice-qt6-fresh
        pkgs.zathura
        pkgs.onlyoffice-desktopeditors
        pkgs.mesa.opencl
        pkgs.wineWow64Packages.stagingFull
        pkgs.krita
        # pkgs.affinity-v3
        # (pkgs.writeShellApplication {
        #   name = "affinity-fix";
        #   runtimeInputs = [ pkgs.affinity-v3 ];
        #   text = ''
        #     # We are so unbelievably cooked
        #     affinity-v3 wine "$HOME/.local/share/affinity-v3/drive_c/Program Files/Affinity/Affinity/Affinity.exe"
        #   '';
        # })
        (
          let
            item = {
              name = "affinity-fix";
              desktopName = "Affinity (workaround for plugin-loader crash)";
              icon = "affinity-v3";
              exec = item.name;
            };
          in
          pkgs.makeDesktopItem item
        )
      ];
      i18n.inputMethod = {
        enable = true;
        type = "ibus";
        ibus.waylandFrontend = true;
        ibus.engines = [
          pkgs.ibus-engines.typing-booster
          pkgs.openbangla-keyboard
        ];
      };
      fonts.packages = [
        pkgs.corefonts
        pkgs.winePackages.fonts
      ];
    };
in
{
  flake.wrappers.niri-pc.settings.spawn-at-startup = [
    [
      "ibus"
      "start"
      "--type"
      "wayland"
    ]
  ];
  flake.modules.nixos = {
    work = productivity;
    tjmaxxer = productivity;
  };
}
