# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, inputs, ... }:
let
  inherit (config.flake) packages;
in
{
  perSystem.niri.settings.spawn-at-startup = [
    "ibus"
    "start"
    "--type"
    "wayland"
  ];
  flake.modules.nixos.pc =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      cfg = config.hardware.graphics;

      # Nixpkgs makes some truly degenerate ibus desktop entries
      killIbusAutostart = pkgs.writeTextFile {
        name = "kill-autostart-ibus-daemon";
        destination = "/etc/xdg/autostart/ibus-daemon.desktop";
        text = "";
      };
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [
        (lib.mkForce killIbusAutostart)
        packages.${system}.naps2-wrapped
        inputs.affinity-nix.packages.${system}.v3
        inputs.zen-browser.packages.${system}.default
        pkgs.hunspell
        pkgs.hunspellDicts.en-gb-large
        pkgs.libreoffice-qt6-fresh
        pkgs.logseq
        pkgs.zathura
        pkgs.onlyoffice-desktopeditors
        (pkgs.writeShellApplication {
          name = "affinity-fix";
          runtimeInputs = [ inputs.affinity-nix.packages.${system}.v3 ];
          text = ''
            affinity-v3 || affinity-v3
          '';
        })
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
          pkgs.ibus-engines.openbangla-keyboard
        ];
      };
      fonts.packages = [
        pkgs.corefonts
        pkgs.winePackages.fonts
      ];
      systemd.user.tmpfiles.rules = lib.lists.forEach config.fonts.packages (pkg: ''
        C+ %h/.local/share/fonts/${pkg.pname} 0755 - - - ${pkg}/share/fonts/
        z %h/.local/share/fonts/${pkg.pname}/* 0755 - - -
      '');
    };

}
