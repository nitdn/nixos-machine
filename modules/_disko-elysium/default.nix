{
  config,
  inputs,
  moduleWithSystem,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  nixosModules = config.flake.modules.nixos;
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

  flake.modules.nixos.hmPerUser = moduleWithSystem (
    { config, ... }:
    let
      inherit (config.pc) username;
      inherit homeModules;
    in
    {
      imports = [
        nixosModules.hmBase
      ];
      home-manager.users."${username}" = homeModules.default;
    }
  );

  flake.nixosConfigurations.disko-elysium = inputs.nixpkgs.lib.nixosSystem {
    modules = with nixosModules; [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      default
      config.flake.modules.generic.light
      hmPerUser
      ./configuration.nix
      {
        home-manager.sharedModules = [
          homeModules.light
        ];
      }
    ];
  };
}
