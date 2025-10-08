{
  description = "Tjmaxxer nixos machine";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
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

      {
        debug = true;
        pc.username = username;

        imports = [
          # Optional: use external flake logic, e.g.
          inputs.home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule
          ./pc
          ./vps
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem =
          {
            pkgs,
            system,
            ...
          }:
          let

            buildInputs = [
              pkgs.makeWrapper
              pkgs.libtiff.out
            ];
          in
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.nix-on-droid.overlays.default
              ];
            };
            # packages.typeman = inputs'.typeman.packages.default;
            packages.epson-l3212 = pkgs.callPackage ./epson-l3212.nix { };
            packages.bizhub-225i-ppds = pkgs.callPackage ./bizhub-225i.nix { };
            packages.naps2-wrapped = pkgs.naps2.overrideAttrs (
              finalAttrs: previousAttrs: {
                buildInputs = previousAttrs.buildInputs or [ ] ++ buildInputs;
                postFixup = previousAttrs.postFixup or "" + ''
                  chmod +x $out/lib/naps2/_linux/tesseract 
                  wrapProgram $out/bin/naps2 --prefix LD_LIBRARY_PATH : \
                  ${builtins.toString (pkgs.lib.makeLibraryPath buildInputs)}
                '';
              }
            );
            treefmt.programs = {
              dprint.enable = true;
              nixfmt.enable = true;
              just.enable = true;
              sqlfluff.enable = true;
              sqlfluff.dialect = "postgres";
            };
            treefmt.programs.dprint.excludes = [
              "**/*-lock.json"
            ];
            treefmt.programs.dprint.settings.plugins = (
              pkgs.dprint-plugins.getPluginList (
                plugins: with plugins; [
                  dprint-plugin-json
                  dprint-plugin-markdown
                  dprint-plugin-toml
                  g-plane-pretty_yaml
                ]
              )
            );

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                just
                vscode-langservers-extracted
                eww
                meld
                nixfmt-rfc-style
                nixd
              ];
            };
          };
      };

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io/"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

}
