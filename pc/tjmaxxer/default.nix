{
  config,
  inputs,
  ...
}:
let
  homeModule = config.flake.modules.homeManager.default;
  nixosModules = config.flake.modules.nixos;

in
{
  flake.nixosConfigurations.tjmaxxer = inputs.nixpkgs.lib.nixosSystem {

    modules = [
      nixosModules.default
      ./configuration.nix
    ];
  };

  perSystem =
    { pkgs, config, ... }:
    let
      inherit (config) pc;
      username = pc.username;
    in
    {
      legacyPackages.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          homeModule
          ../stylix.nix
          inputs.stylix.homeModules.stylix
          inputs.zen-browser.homeModules.default
          inputs.niri.homeModules.niri
          inputs.niri.homeModules.stylix
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            programs.niri.enable = true;
            nixpkgs.overlays = [
              inputs.niri.overlays.niri
            ];
          }
        ];
      };
    };
}
