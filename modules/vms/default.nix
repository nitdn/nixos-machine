# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, lib, ... }:

let
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
  };
  flake.modules.nixos.pc = {
    image.modules = lib.genAttrs [ "iso" "iso-installer" ] (_: {
      imports = [ nixosModules.vm ];
      boot.supportedFilesystems.zfs = lib.mkForce false;
    });
    virtualisation.vmVariant = {
      imports = [ nixosModules.vm ];
    };
  };

}
