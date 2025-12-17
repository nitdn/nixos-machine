{ inputs, ... }:
{
  flake.modules.nixos.msi-colgate = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/ata-CONSISTENT_SSD_S7_512GB_6IGIPGP17RTPT4UEBT5V";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                priority = 1;
                name = "ESP";
                start = "1M";
                end = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              plainSwap = {
                size = "16G";
                content = {
                  type = "swap";
                  discardPolicy = "both";
                };
              };
              root = {
                size = "100G";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
              home = {
                size = "200G";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
