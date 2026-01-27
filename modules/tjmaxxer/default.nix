# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  inputs,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  nixosModules = config.flake.modules.nixos;
  inherit (config.meta) username;
in
{
  flake.modules.nixos.tjmaxxer =
    { pkgs, ... }:
    {
      hardware.facter.reportPath = ./facter.json;
      hardware.ckb-next.enable = true;
      hardware.ckb-next.package = pkgs.ckb-next.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DUSE_DBUS_MENU=0" ];
      });
      hardware.graphics = {
        enable32Bit = true;
        extraPackages = [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          pkgs.intel-media-driver # VA-API (iHD) userspace
          pkgs.vpl-gpu-rt # oneVPL (QSV) runtime
        ];
        extraPackages32 = [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          pkgs.pkgsi686Linux.intel-media-driver # VA-API (iHD) userspace
        ];
      };
      # May help if FFmpeg/VAAPI/QSV init fails (esp. on Arc with i915):
      hardware.enableRedistributableFirmware = true;
      boot.kernelParams = [ "i915.enable_guc=3" ];
      networking.hostName = "tjmaxxer"; # Define your hostname.
      # I did not read the comment
      system.stateVersion = "24.11";
      users.users.${username} = {
        enable = false;
        isNormalUser = true;
      };
      home-manager.users.${username} = homeModules.pc;
    };

  flake.nixosConfigurations.tjmaxxer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixosModules.pc
      nixosModules.tjmaxxer
      nixosModules.hmBase
    ];
  };
}
