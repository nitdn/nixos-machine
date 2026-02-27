# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.meta) username;
in
{
  options = {
    meta.username = lib.mkOption {
      type = lib.types.str;
    };
    meta.unfreeNames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    meta.term = lib.mkOption {
      type = lib.types.str;
    };
  };
  config.meta.username = "ssmvabaa";
  config.flake.modules.nixos = {
    pc = {
      imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.nix-index-database.nixosModules.default
      ];
      nixpkgs.overlays = [
        config.flake.overlays.default
      ];

      # This will add secrets.yml to the nix store
      # You can avoid this by adding a string to the full path instead, i.e.
      # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
      sops.defaultSopsFile = ../secrets/core.yaml;
      # This is using an age key that is expected to already be in the filesystem
      sops.age.keyFile = "/var/lib/sops-nix/key.txt";
      # This will generate a new key if the key specified above does not exist
      sops.age.generateKey = true;

      nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) config.meta.unfreeNames;
    };
    work =
      { pkgs, ... }:
      {
        networking.useDHCP = lib.mkDefault true;
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
            pkgs.github-cli
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
        inputs.authentik-nix.nixosModules.default
      ];
    };
  };
}
