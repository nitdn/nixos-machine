# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:

let
  homeModule = config.flake.modules.homeManager.pc;
  nixosModules = config.flake.modules.nixos;

in
{
  flake.modules.nixos.vm =
    { lib, ... }:
    {
      imports = [
        nixosModules.hmBase
      ];
      services.btrfs.autoScrub.enable = false;
      hardware.facter.reportPath = lib.mkForce null;
      boot.initrd.systemd.repart.device = lib.mkForce null;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      users.users.vmtest = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        initialPassword = "vmtest";
      };
      home-manager.users."vmtest" = homeModule;
    };
}
