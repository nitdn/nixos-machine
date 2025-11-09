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

  flake.modules.nixos.msi-colgate = moduleWithSystem (
    { config, pkgs, ... }:
    let
      inherit homeModules;
    in
    {
      imports = [
        generic.light
      ];
      networking.useDHCP = true;
      facter.reportPath = ./facter.json;
      networking.hostName = "msi-colgate"; # Define your hostname.
    }
  );

  flake.nixosConfigurations.msi-colgate = inputs.nixpkgs.lib.nixosSystem {
    modules = with nixosModules; [
      pc
      work
      msi-colgate
      hmBase
    ];
  };
}
