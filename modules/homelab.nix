# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This is a homelab skeleton, please look at modules to see
# what the homelabs actually use

{ lib, config, ... }:
let
  module = config.flake.modules.nixos.homelab;
in
{
  flake.modules.nixos.homelab =
    { config, pkgs, ... }:

    let
      port = config.services.nix-serve.port |> lib.toString;
    in
    {
      # All homelabs will serve their nix stores
      # load balanced by tailscale
      # assuming I ever get more than one homelabs lol

      services.nix-serve = {
        enable = true;
        package = pkgs.nix-serve-ng;
        secretKeyFile = "/var/lib/nix-serve/secret-key-file";
      };

      # SSH based user for github runners
      # will be used as an allowed user
      users.users."gh-runner" = {
        isSystemUser = true;
        shell = pkgs.bashInteractive;
        group = "gh-runner";
      };
      users.groups."gh-runner" = { };
      nix.settings.trusted-users = [ "gh-runner" ];

      services.tailscale.serve = {
        enable = false;
        services.nix-serve.endpoints."tcp:443" = "https://localhost:${port}";
      };
    };

  flake.modules.nixos = {
    disko-elysium.imports = [ module ];
  };
}
