# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  lib,
  ...
}:

let
  nixosModules = config.flake.modules.nixos;
in
{
  flake.modules.nixos = {
    vm = {
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
    iso =
      { modulesPath, ... }:
      {
        imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
        # Repart will just try to endlessly initialize hardware that may not exist
        hardware.facter = lib.mkForce { };
        hardware.graphics = lib.mkForce { enable = false; };
        boot.initrd.systemd.repart.device = lib.mkForce null;
        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        services.btrfs.autoScrub.enable = false;
        isoImage.squashfsCompression = "zstd -Xcompression-level 6";
      };
    pc = {
      image.modules.iso.imports = [ nixosModules.iso ];
      image.modules.iso-installer.imports = [ nixosModules.iso ];
      virtualisation.vmVariant = {
        imports = [ nixosModules.vm ];
      };
    };
  };
}
