{
  self,
  inputs,
  lib,
  withSystem,
  username,
  ...
}:
{
  config = {
    flake.nixosConfigurations.tjmaxxer = (
      {
        config,
        ...
      }:

      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          packages = config.packages;
          inherit inputs username;
        };

        modules = [
          inputs.sops-nix.nixosModules.sops
          inputs.stylix.nixosModules.stylix
          inputs.niri.nixosModules.niri
          ./pc/tjmaxxer/configuration.nix
          ./pc/stylix.nix
          {
            imports = [
            ];
            programs.niri.enable = true;
            nixpkgs.overlays = [
              inputs.niri.overlays.niri
              inputs.helix.overlays.default
            ];
          }
        ];
      }
    );

    flake.homeConfigurations.${username} = withSystem "x86_64-linux" (
      {
        config,
        pkgs,
        inputs',
        ...
      }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./pc/home.nix
          ./pc/stylix.nix
          inputs.stylix.homeModules.stylix
          inputs.zen-browser.homeModules.default
          inputs.niri.homeModules.niri
          inputs.niri.homeModules.stylix
          {
            programs.niri.enable = true;
            nixpkgs.overlays = [
              inputs.niri.overlays.niri
              self.overlays.default
            ];
            nixpkgs.config.allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "obsidian"
              ];
          }
        ];
        extraSpecialArgs = {
          packages = config.packages;
          inherit self inputs' username;
        };
      }
    );

  };
}
