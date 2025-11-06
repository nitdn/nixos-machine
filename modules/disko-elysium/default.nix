{
  config,
  inputs,
  moduleWithSystem,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  nixosModules = config.flake.modules.nixos;
  username = config.meta.username;
  inherit (config.flake.modules) generic;
in
{
  flake.modules.homeManager.light = {
    imports = [ config.flake.modules.generic.light ];
    programs.helix.settings.theme = "ayu_light";
    programs.noctalia-shell.settings.colorSchemes.darkMode = "false";
  };

  flake.modules.generic.light =
    { pkgs, ... }:
    {
      stylix.polarity = "light";
      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-light.yaml";
    };

  flake.modules.nixos.disko-elysium = moduleWithSystem (
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
      facter.reportPath = ./facter.json;
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
      networking.hostName = "disko-elysium"; # Define your hostname.
      system.stateVersion = "25.05"; # Did you read the comment?
    }
  );

  flake.nixosConfigurations.disko-elysium = inputs.nixpkgs.lib.nixosSystem {
    modules = with nixosModules; [
      pc
      disko-elysium
      hmBase
    ];
  };
}
