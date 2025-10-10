{
  config,
  inputs,
  ...
}:
let
  inherit (config) pc;
  username = pc.username;
  homeModule = config.flake.modules.homeManager.default;
  nixosModules = config.flake.modules.nixos;
in
{
  flake.nixosConfigurations.disko-elysium =

    inputs.nixpkgs.lib.nixosSystem {

      modules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        nixosModules.default
        ./configuration.nix

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            inputs.zen-browser.homeModules.default
          ];
          home-manager.backupFileExtension = "backup";
          home-manager.users.${username} = {
            imports = [ homeModule ];
            programs.helix.settings.theme = "ayu_light";
          };
        }
      ];
    }
  # )
  ;
}
