# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.work =
    { pkgs, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "input"
          "i2c"
          "dialout"
          "lp"
        ]; # Enable sudo for the user.
        packages = [
          pkgs.tree
        ];
      };
      environment.systemPackages = [
        pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        pkgs.wget
      ];
    };
}
