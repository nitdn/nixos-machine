{ inputs, ... }:
{
  flake.modules.nixos.disko-elysium = {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/disk/by-id/ata-CT500MX500SSD1_2224E63B5151";
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
