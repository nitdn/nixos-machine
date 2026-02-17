# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.msi-colgate = {
    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd"
      ];
    };
    fileSystems."/home" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
      ];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      neededForBoot = true;
      options = [
        "subvol=@nix"
        "noatime"
        "compress=zstd"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
