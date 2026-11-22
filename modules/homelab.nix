# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This is a homelab skeleton, please look at modules to see
# what the homelabs actually use

{
  config,
  inputs,
  ...
}:
let
  module = config.flake.modules.nixos.homelab;
in
{
  flake.modules.nixos.homelab =
    { config, pkgs, ... }:

    let
      port = 8080;
      username = config.services.cellerd.user;
      domainName = "curlew-rankine.ts.net";
      hostname = "cache.${domainName}";
    in
    {
      imports = [ inputs.celler.nixosModules.cellerd ];
      # All homelabs will serve their nix stores
      # load balanced by tailscale
      # assuming I ever get more than one homelabs lol
      #
      sops.secrets.celler-env = { };

      services.cellerd = {
        enable = true;
        environmentFile = config.sops.secrets.celler-env.path;
        settings = {
          database.url = "postgresql://${username}?host=/run/postgresql";
          allowed-hosts = [ hostname ];
          api-endpoint = "https://${hostname}/";
          storage = {
            type = "s3";
            region = "garage";
            bucket = "celler";
            endpoint = "https://garage.${domainName}";
          };
          garbage-collection.default-retention-period = "12 hours";

          jwt = {
            rs256-public-key-file = ./celler/public-key.pem;
          };
        };

      };
      services.postgresql = {
        ensureDatabases = [ username ];
        ensureUsers = [
          {
            name = username;
            ensureDBOwnership = true;
          }
        ];
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
        # TODO: > must be a URL starting with one of the supported schemes: [tcp unix]
        # they literally do not support the config they export
        # what a joke
        services.cache.endpoints."tcp:443" = "tls-terminated-tcp://localhost:${port |> toString}";
      };
    };

  flake.modules.nixos = {
    disko-elysium.imports = [ module ];
    pc =
      { pkgs, ... }:
      let
        inherit (pkgs.stdenv.hostPlatform) system;
        clientPackage = inputs.celler.packages.${system}.default;
      in
      {
        environment.systemPackages = [ clientPackage ];
      };
  };
}
