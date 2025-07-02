{
  description = "Tjmaxxer nixos machine";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
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
          perSystem =
            {
              pkgs,
              config,
              ...
            }:
            {
              devShells.default = pkgs.mkShell {
                packages = [
                  pkgs.just
                  pkgs.vscode-langservers-extracted
                  pkgs.eww
                ];
              };
            };
          flake = withSystem "x86_64-linux" (
            {
              config,
              inputs',
              pkgs,
              ...
            }:

            {
              nixosConfigurations.tjmaxxer = inputs.nixpkgs.lib.nixosSystem {
                specialArgs = {
                  packages = config.packages;
                  inherit inputs inputs' username;
                };

                modules = [
                  ./pc/tjmaxxer/configuration.nix
                  ./pc/stylix.nix
                  inputs.sops-nix.nixosModules.sops
                  inputs.stylix.nixosModules.stylix
                  inputs.niri.nixosModules.niri
                  {
                    programs.niri.enable = true;
                    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
                  }
                ];
              };

              homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  ./pc/home.nix
                  ./pc/stylix.nix
                  inputs.stylix.homeModules.stylix
                  inputs.zen-browser.homeModules.twilight
                  inputs.niri.homeModules.niri
                  inputs.niri.homeModules.stylix
                  {
                    programs.niri.enable = true;
                    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
                  }
                ];
                extraSpecialArgs = {
                  inherit self username;
                };
              };

              nixosConfigurations.vps01 = inputs.nixpkgs.lib.nixosSystem {
                modules = [
                  inputs.disko.nixosModules.disko
                  {
                    networking.useDHCP = inputs.nixpkgs.lib.mkForce false;
                    services.cloud-init = {
                      enable = true;
                      network.enable = true;
                    };
                  }
                  ./vps/configuration.nix
                  inputs.nixos-facter-modules.nixosModules.facter
                  inputs.sops-nix.nixosModules.sops
                  {
                    config.facter.reportPath =
                      if builtins.pathExists ./vps/facter.json then
                        ./vps/facter.json
                      else
                        throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./vps/facter.json`?";
                  }
                ];
              };
            }
          );
        }
      );
}
