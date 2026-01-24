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
      environment.systemPackages = with pkgs; [
        #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        #  wget
        adwaita-icon-theme
        bat
        dust
        eza
        ghostty
        git
        gparted
        ldns # drill
        openssl
        pwgen
        ripgrep
        sops
        trash-cli
        vulkan-tools
        wineWowPackages.stagingFull
      ];
      environment.variables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };
    };
}
