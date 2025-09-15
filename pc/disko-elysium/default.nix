{
  config,
  withSystem,
  inputs,
  ...
}:
let
  username = pc.username;
  pc = config.pc;
in
{
  config = {

    flake.nixosConfigurations.disko-elysium = withSystem "x86_64-linux" (
      {
        config,
        inputs',
        ...
      }:

      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          packages = config.packages;
          inherit inputs pc;
        };

        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.stylix.nixosModules.stylix
          inputs.niri.nixosModules.niri
          inputs.home-manager.nixosModules.home-manager
          ./configuration.nix
          ../stylix.nix
          {
            imports = [
            ];
            programs.niri.enable = true;
            nixpkgs.overlays = [
              inputs.niri.overlays.niri
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              inputs.zen-browser.homeModules.default
            ];
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = ./home.nix;
            home-manager.extraSpecialArgs = {
              packages = config.packages;
              inherit inputs' pc;
            };
          }
        ];
      }
    );
  };
}
