{
  flake.modules.nixos.tjmaxxer = {
    # boot.kernelParams = [
    #   "systemd.log_level=debug"
    #   "systemd.log_target=kmsg"
    #   "log_buf_len=1M"
    #   "printk.devkmsg=on"
    #   "enforcing=0"
    # ];

    # diagnose shutdown slowness
    # systemd.shutdown."debug.sh" = pkgs.writeScript "debug.sh" ''
    #   #!/bin/sh
    #   mount -o remount,rw /
    #   dmesg > /shutdown-log.txt
    #   mount -o remount,ro /
    # '';
    services.homed.enable = true;
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.repart.enable = true;
    boot.initrd.systemd.repart.device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_24184R805268";

    systemd.repart.partitions."30-boot" = {
      Type = "esp";
      SizeMinBytes = "1G";
      SizeMaxBytes = "2G";
      Format = "vfat";
      Label = "wd-efi";
    };

    systemd.repart.partitions."40-swap" = {
      Type = "swap";
      SizeMinBytes = "8G";
      SizeMaxBytes = "20G";
      Label = "wd-swap";
    };

    systemd.repart.partitions."10-root" = {
      Type = "root";
      SizeMinBytes = "100G";
      SizeMaxBytes = "200G";
      # Format = "btrfs";
      Label = "nixos-root-b";
      CopyBlocks = "/dev/disk/by-partlabel/nixos-root-a";
    };

    systemd.repart.partitions."20-home" = {
      Type = "home";
      SizeMinBytes = "100G";
      SizeMaxBytes = "300G";
      Format = "btrfs";
      Label = "systemd-home";
    };

    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/nixos-root-b";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd"
      ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/wd-efi";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

  };
}
