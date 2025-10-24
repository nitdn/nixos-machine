{
  config,
  inputs,
  moduleWithSystem,
  ...
}:
let
  homeModule = config.flake.modules.homeManager.default;
  nixosModules = config.flake.modules.nixos;

in
{
  flake.modules.nixos.ckb-next = moduleWithSystem (
    { inputs', ... }:
    {
      hardware.ckb-next.enable = true;
      hardware.ckb-next.package = inputs'.stablepkgs.legacyPackages.ckb-next;
    }
  );
  flake.nixosConfigurations.tjmaxxer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixosModules.default
      nixosModules.ckb-next
      ./configuration.nix
    ];
  };

  flake.nixosConfigurations.tjmaxxer-vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      nixosModules.hmBase
      ./hardware-configuration.nix
      {
        users.users.alice = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          initialPassword = "test";
        };
        home-manager.users."alice" = homeModule;
        networking.hostName = "tjmaxxer"; # Define your hostname.
        system.stateVersion = "25.11"; # This will track unstable because of lore reasons
      }
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
