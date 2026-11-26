# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This is a homelab skeleton, please look at modules to see
# what the homelabs actually use

{
  config,
  inputs,
  lib,
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
      cfg = config.caddyProxy;
    in
    {
      options.caddyProxy = lib.mkOption {
        type = lib.types.attrsOf lib.types.int;
        description = "Enter in <name> = <port> format";
      };

      imports = [ inputs.celler.nixosModules.cellerd ];
      # All homelabs will serve their nix stores
      # load balanced by tailscale
      # assuming I ever get more than one homelabs lol
      #
      config = {
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
            garbage-collection.default-retention-period = "8 days";

            jwt = {
              rs256-public-key-file = ./celler/public-key.pem;
            };
          };
        };
        caddyProxy = {
          cache = port;
        };
        services.caddy.virtualHosts = lib.mapAttrs' (
          svcName: port:
          lib.nameValuePair ("${svcName}.${domainName}") {
            extraConfig = ''
              # Forward Auth
              forward_auth unix/${config.services.tailscaleAuth.socketPath} {
              uri /auth
              header_up Remote-Addr {remote_host}
              header_up Remote-Port {remote_port}
              header_up Original-URI {uri}
              copy_headers {
                Tailscale-User>X-Webauth-User
                Tailscale-Name>X-Webauth-Name
                Tailscale-Login>X-Webauth-Login
                Tailscale-Tailnet>X-Webauth-Tailnet
                Tailscale-Profile-Picture>X-Webauth-Profile-Picture
                }
              }
              reverse_proxy :${toString port}
            '';
          }
        ) cfg;
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
          enable = true;
          # TODO: > must be a URL starting with one of the supported schemes: [tcp unix]
          # they literally do not support the config they export
          # what a joke
          services = lib.mapAttrs (_svcName: value: {
            endpoints."tcp:443" = "tcp://localhost:443";
            endpoints."tcp:80" = "tcp://localhost:80";
          }) cfg;
        };
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
