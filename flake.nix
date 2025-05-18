{
  description = "Tjmaxxer nixos machine";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      flake-parts,
      ...
    }@inputs:
    let
      username = "ssmvabaa";
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      (
        {
          self,
          withSystem,
          ...
        }:
        {
          debug = true;

          imports = [
            # Optional: use external flake logic, e.g.
            inputs.home-manager.flakeModules.home-manager
          ];
          systems = [ "x86_64-linux" ];
          flake = withSystem "x86_64-linux" (
            {
              pkgs,
              config,
              inputs',
              ...
            }:
            {
              nixosConfigurations.tjmaxxer = inputs.nixpkgs.lib.nixosSystem {
                specialArgs = {
                  packages = config.packages;
                  inherit inputs inputs';
                };

                modules = [
                  ./configuration.nix
                  ./systemd.nix
                  ./stylix.nix
                  inputs.sops-nix.nixosModules.sops
                  inputs.stylix.nixosModules.stylix
                ];
              };
              homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  ./home.nix
                  ./stylix.nix
                  inputs.stylix.homeModules.stylix
                ];
                extraSpecialArgs = {
                  inherit self username;
                };
              };
            }
          );
        }
      );
}
