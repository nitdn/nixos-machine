{
  config,
  inputs,
  lib,
  moduleWithSystem,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  nixosModules = config.flake.modules.nixos;
  username = config.meta.username;
in
{
  flake.modules.nixos.tjmaxxer = moduleWithSystem (
    { inputs', pkgs, ... }:
    {
      facter.reportPath = ./facter.json;
      hardware.ckb-next.enable = true;
      hardware.ckb-next.package = inputs'.stablepkgs.legacyPackages.ckb-next;
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

    }
  );
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
