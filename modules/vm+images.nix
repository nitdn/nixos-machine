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
  flake.modules.nixos.pc =
    let
      baseModules = {
        imports = [ nixosModules.vm ];
        boot.supportedFilesystems.zfs = lib.mkForce false;
        isoImage.squashfsCompression = "zstd -Xcompression-level 3";
      };
    in
    {
      image.modules.iso = baseModules;
      image.modules.iso-installer = baseModules;
      virtualisation.vmVariant = {
        imports = [ nixosModules.vm ];
      };
    };

  flake.modules.nixos.isoBootstrap =
    { pkgs, modulesPath, ... }:
    {
      image.modules.iso-installer = {
        imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
        isoImage.squashfsCompression = "zstd -Xcompression-level 3";
      };
      environment.systemPackages = [
        pkgs.helix
        pkgs.jujutsu
        pkgs.nh
      ];
    };
  flake.nixosConfigurations.isoBootstrap = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = lib.attrValues { inherit (nixosModules) isoBootstrap; };
  };
}
