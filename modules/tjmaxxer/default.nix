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
      facter.reportPath = ./facter.json;
      hardware.ckb-next.enable = true;
      hardware.ckb-next.package = pkgs.ckb-next.overrideAttrs (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DUSE_DBUS_MENU=0" ];
      });
      hardware.graphics = {
        enable32Bit = true;
        extraPackages = with pkgs; [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          intel-media-driver # VA-API (iHD) userspace
          vpl-gpu-rt # oneVPL (QSV) runtime
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          intel-media-driver # VA-API (iHD) userspace
        ];
      };
      # May help if FFmpeg/VAAPI/QSV init fails (esp. on Arc with i915):
      hardware.enableRedistributableFirmware = true;
      boot.kernelParams = [ "i915.enable_guc=3" ];
      networking.hostName = "tjmaxxer"; # Define your hostname.
      system.stateVersion = "24.11"; # I did not read the comment

    };
  flake.nixosConfigurations.tjmaxxer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixosModules.pc
      nixosModules.tjmaxxer
    ];
  };
  flake.nixosConfigurations.tjmaxxer-vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixosModules.pc
      nixosModules.vm
      nixosModules.tjmaxxer
    ];
  };
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          homeModules.pc
          homeModules.standalone
        ];
      };
    };
}
