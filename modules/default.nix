{
  config,
  inputs,
  lib,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  nixosModules = config.flake.modules.nixos;
  username = config.meta.username;
  inherit (config.flake.modules) generic;
in
{
  options = {
    meta.username = lib.mkOption {
      type = lib.types.str;
    };
    meta.unfreeNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config.flake.modules.nixos = {
    pc = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.nixos-facter-modules.nixosModules.facter
      ];
      nixpkgs.overlays = [
        config.flake.overlays.default
      ];
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.meta.unfreeNames;
    };
    work =
      { config, pkgs, ... }:
      let
        inherit homeModules;
      in
      {
        imports = [
          generic.light
        ];
        boot.kernelPackages = pkgs.linuxPackages_latest;
        networking.useDHCP = true;
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "input"
          ]; # Enable ‘sudo’ for the user.
          packages = with pkgs; [
            tree
          ];
        };
        home-manager.users."${username}" = homeModules.pc;
        boot.kernelModules = [ "ecryptfs" ];
        security.pam.enableEcryptfs = true;
        environment.systemPackages = with pkgs; [
          vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
          wget
          ecryptfs
        ];
        home-manager.sharedModules = [
          homeModules.light
        ];
        system.stateVersion = "25.05"; # Did you read the comment?
      };

    vps = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.authentik-nix.nixosModules.default
        inputs.nixos-facter-modules.nixosModules.facter
      ];
    };
  };
}
