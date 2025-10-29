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
      imports = [
        inputs.nixos-facter-modules.nixosModules.facter
      ];
      facter.reportPath = ./facter.json;
      hardware.ckb-next.enable = true;
      hardware.ckb-next.package = inputs'.stablepkgs.legacyPackages.ckb-next;
      hardware.graphics = {
        extraPackages = with pkgs; [
          # Required for modern Intel GPUs (Xe iGPU and ARC)
          intel-media-driver # VA-API (iHD) userspace
          vpl-gpu-rt # oneVPL (QSV) runtime
        ];
      };
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
