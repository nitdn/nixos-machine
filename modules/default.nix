# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
let
  inherit (config.meta) username; # dummy value as the fetcher doesnt really care
  # a way to fetch nix files via nvfetcher and import them in the config
  # basically parse the json crated by nvfetcher, and use fetchTarball
  # nvfetcher uses fetchers from nixpkgs by default, so we can't use the generated.nix file here
  # but can everywhere else.
  sourcesJson = builtins.fromJSON (builtins.readFile ../_sources/generated.json);

  modules =
    builtins.mapAttrs
      (
        _name: value:
        let
          src = fetchTree {
            inherit (value.src)
              owner
              repo
              rev
              type
              ;
          };
        in
        value // { inherit src; }
      )
      (
        removeAttrs sourcesJson [
          "bizhub-225i"
          "epson-202101w"
          "matugen-themes"
        ]
      );

in
{
  options = {
    meta.username = lib.mkOption {
      type = lib.types.str;
    };
    meta.term = lib.mkOption {
      type = lib.types.str;
    };
    flake.sources = {
      modules = lib.mkOption {
        type = lib.types.anything;
      };
      raw = lib.mkOption {
        type = lib.types.anything;
      };
    };
  };
  config.meta.username = "ssmvabaa";
  config.flake.sources.modules = modules;
  config.flake.sources.raw = ../_sources/generated.nix;

  config.flake.modules.nixos = {
    pc =
      {
        pkgs,
        config,
        ...
      }:
      {
        imports = [
          inputs.sops-nix.nixosModules.sops
          inputs.nix-index-database.nixosModules.default
        ];
        # Use the configured pkgs from perSystem
        nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
          { pkgs, ... }: # perSystem module arguments
          pkgs
        );
        # This will add secrets.yml to the nix store
        # You can avoid this by adding a string to the full path instead, i.e.
        # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
        sops.defaultSopsFile = ../secrets/core.yaml;
        # This is using an age key that is expected to already be in the filesystem
        sops.age.keyFile = "/var/lib/sops-nix/key.txt";
        # This will generate a new key if the key specified above does not exist
        sops.age.generateKey = true;
        users.users.${username} = {
          # For some reason it actually still fucking works
          packages = lib.attrValues { inherit (pkgs) vlc github-cli; };
        };

      };
    work =
      { pkgs, ... }:
      {
        users.users.${username} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "input"
            "i2c"
            "dialout"
            "lp"
          ]; # Enable ‘sudo’ for the user.
          packages = [
            pkgs.tree
          ];
        };
        environment.systemPackages = [
          pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
          pkgs.wget
        ];
        system.stateVersion = "25.05"; # Did you read the comment?
      };
    vps = {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
    };
  };
}
