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
  vm = _: {
    virtualisation = {
      cores = 4;
      memorySize = 4 * 1024;
      qemu.options = [
        "-display gtk,gl=on"
        "-device virtio-vga-gl,hostmem=4G,blob=true,venus=true"
      ];
    };

    services.btrfs.autoScrub.enable = false;
    hardware.facter.reportPath = lib.mkForce null;
    boot.initrd.systemd.repart.device = lib.mkForce null;
    boot.zswap.enable = lib.mkForce false; # cant use that in a vm anyway

    users.users.vmtest = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "vmtest";
    };
  };
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
    iso = {
      # TODO kill this line after NixOS 26.11
      boot.zfs.forceImportRoot = false;
      image.modules.iso-installer.isoImage.squashfsCompression = "zstd -Xcompression-level 6";
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    pc = {
      imports = [
        inputs.microvm.nixosModules.host
      ];
      virtualisation.vmVariant = vm;
    };
  };
}
