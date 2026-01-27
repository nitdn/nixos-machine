# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  inherit (config.meta) username;
in

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {

      security.sudo.extraRules = [
        {
          users = [ username ];
          commands = [ "ALL" ];
        }
      ];
      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = [
        #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        #  wget
        pkgs.adwaita-icon-theme
        pkgs.bat
        pkgs.dust
        pkgs.eza
        pkgs.ghostty
        pkgs.git
        pkgs.gparted
        pkgs.ldns # drill
        pkgs.openssl
        pkgs.pwgen
        pkgs.ripgrep
        pkgs.sops
        pkgs.trash-cli
        pkgs.vulkan-tools
        pkgs.wineWowPackages.stagingFull
      ];
      environment.variables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };
    };
}
