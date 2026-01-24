# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, lib, ... }:

let
  homeModule = config.flake.modules.homeManager.pc;
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos.vm = {
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
  flake.modules.nixos.pc = {
    image.modules = {
      iso = {
        imports = [ nixosModules.vm ];
        boot.supportedFilesystems = lib.mkForce [
          "btrfs"
          "cifs"
          "erofs"
          "ext4"
          "f2fs"
          "ntfs"
          "squashfs"
          "vfat"
          "xfs"
        ];
      };
    };
    virtualisation.vmVariant = {
      imports = [ nixosModules.vm ];
    };
  };
}
