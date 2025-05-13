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
    sops-nix.url = "github:Mic92/sops-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";

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
                  inputs.sops-nix.nixosModules.sops
                ];
              };
              homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ ./home.nix ];
                extraSpecialArgs = {
                  inherit self username;
                };
              };
            }
          );
        }
      );
}
