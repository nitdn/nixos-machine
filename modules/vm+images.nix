# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  lib,
  ...
}:

let
  nixosModules = config.flake.modules.nixos;
in
{
  perSystem =
    { system, ... }:
    let
      isoBootstrap = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixosModules.iso
        ];
      };
    in
    {
      packages.isoBootstrap = isoBootstrap.config.system.build.images.iso-installer;
    };
  flake.modules.nixos = {
    vm = {
      virtualisation.qemu.options = [
        "-display gtk,gl=es"
        "-device virtio-vga-gl"
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
    };
    iso = {
      image.modules.iso-installer.isoImage.squashfsCompression = "zstd -Xcompression-level 6";
    };
    pc = {
      virtualisation.vmVariant = {
        imports = [ nixosModules.vm ];
      };
    };
  };
}
