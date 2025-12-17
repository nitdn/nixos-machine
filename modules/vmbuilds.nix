{ config, ... }:

let
  homeModule = config.flake.modules.homeManager.pc;
  nixosModules = config.flake.modules.nixos;

in
{
  flake.modules.nixos.vm = {
    imports = [
      nixosModules.hmBase
    ];
    users.users.vmtest = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "vmtest";
    };
    home-manager.users."vmtest" = homeModule;
  };
}
