# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:

let
  homeModule = config.flake.modules.homeManager.pc;
  nixosModules = config.flake.modules.nixos;

in
{
  flake.modules.nixos.vm = {
    imports = [
      nixosModules.hmBase
    ];
    users.users.vmtest = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "vmtest";
    };
    home-manager.users."vmtest" = homeModule;
  };
}
