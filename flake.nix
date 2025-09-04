{
  description = "Tjmaxxer nixos machine";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    helix = {
      url = "github:helix-editor/helix/25.07.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
    authentik-nix = {
      url = "github:nix-community/authentik-nix";

      ## optional overrides. Note that using a different version of nixpkgs can cause issues, especially with python dependencies
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
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
          lib,
          withSystem,
          ...
        }:
        {
          debug = true;

          imports = [
            # Optional: use external flake logic, e.g.
            inputs.home-manager.flakeModules.home-manager
            inputs.flake-parts.flakeModules.easyOverlay
          ];
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          perSystem =
            {
              pkgs,
              system,
              config,
              ...
            }:
            {
              _module.args.pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [
                  inputs.nix-on-droid.overlays.default
                  inputs.helix.overlays.default
                ];
              };
              overlayAttrs = {
                inherit (config.packages) typeman bizhub-225i-ppds;
              };
              packages.typeman = pkgs.callPackage ./typeman.nix { };
              packages.bizhub-225i-ppds = pkgs.callPackage ./bizhub-225i.nix { };
              devShells.default = pkgs.mkShell {
                packages = with pkgs; [
                  just
                  vscode-langservers-extracted
                  eww
                  meld
                ];
              };
            };
          flake.nixOnDroidConfigurations.default = withSystem "aarch64-linux" (
            { pkgs, ... }:
            inputs.nix-on-droid.lib.nixOnDroidConfiguration {
              modules = [
                ./pc/phone-home/nix-on-droid.nix
                # list of extra modules for Nix-on-Droid system
                # { nix.registry.nixpkgs.flake = nixpkgs; }
                # ./path/to/module.nix

                # or import source out-of-tree modules like:
                # flake.nixOnDroidModules.module
              ];

              # list of extra special args for Nix-on-Droid modules
              extraSpecialArgs = {
                inherit self;
                # rootPath = ./.;
              };
              inherit pkgs;
              # set path to home-manager flake
              home-manager-path = inputs.home-manager.outPath;
            }
          );
          flake.nixosConfigurations.tjmaxxer = withSystem "x86_64-linux" (
            {
              config,
              inputs',
              ...
            }:

            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                packages = config.packages;
                inherit inputs inputs' username;
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
                    self.overlays.default
                  ];
                }
              ];
            }
          );

          flake.homeConfigurations.${username} = withSystem "x86_64-linux" (
            { pkgs, ... }:
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
                inherit self username;
              };
            }
          );

          flake.nixosConfigurations.vps01 = inputs.nixpkgs.lib.nixosSystem {
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
              inputs.authentik-nix.nixosModules.default
              {
                config.facter.reportPath =
                  if builtins.pathExists ./vps/facter.json then
                    ./vps/facter.json
                  else
                    throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./vps/facter.json`?";
              }
            ];
          };
          flake.nixosConfigurations.disko-elysium = withSystem "x86_64-linux" (
            {
              config,
              inputs',
              ...
            }:

            inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                packages = config.packages;
                inherit inputs inputs' username;
              };

              modules = [
                inputs.disko.nixosModules.disko
                inputs.sops-nix.nixosModules.sops
                inputs.stylix.nixosModules.stylix
                inputs.niri.nixosModules.niri
                inputs.home-manager.nixosModules.home-manager
                ./pc/disko-elysium/configuration.nix
                ./pc/stylix.nix
                {
                  imports = [
                  ];
                  programs.niri.enable = true;
                  nixpkgs.overlays = [
                    inputs.niri.overlays.niri
                    self.overlays.default
                  ];
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.sharedModules = [
                    inputs.zen-browser.homeModules.default
                  ];
                  home-manager.backupFileExtension = "backup";
                  home-manager.users.ssmvabaa = ./pc/disko-elysium/home.nix;
                  home-manager.extraSpecialArgs = {
                    inherit self username;
                  };
                }
              ];
            }
          );
        }
      );
  nixConfig = {
    substituters = [
      "https://niri.cachix.org/"
      "https://cache.garnix.io/"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };

}
