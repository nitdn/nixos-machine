{
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
let
  pc = config.pc;
  username = pc.username;
  homeModule = config.flake.homeModules.default;
  nixosModule = config.flake.nixosModules.default;

in
{
  config = {
    flake.nixosConfigurations.tjmaxxer = withSystem "x86_64-linux" (
      {
        config,
        ...
      }:

      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          packages = config.packages;
          inherit inputs pc;
        };

        modules = [
          inputs.sops-nix.nixosModules.sops
          inputs.stylix.nixosModules.stylix
          inputs.niri.nixosModules.niri
          ./configuration.nix
          nixosModule
          {
            # imports = [
            # ];
            # programs.niri.enable = true;
            # nixpkgs.overlays = [
            #   inputs.niri.overlays.niri
            #   inputs.helix.overlays.default
            # ];
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
          homeModule
          ../stylix.nix
          inputs.stylix.homeModules.stylix
          inputs.zen-browser.homeModules.default
          inputs.niri.homeModules.niri
          inputs.niri.homeModules.stylix
          {
            home.homeDirectory = "/home/${username}";
            programs.niri.enable = true;
            nixpkgs.overlays = [
              inputs.niri.overlays.niri
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
          inherit inputs';
        };
      }
    );

  };
}
