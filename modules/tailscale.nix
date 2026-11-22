# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
_: {
  flake.modules.nixos = {
    pc =
      {
        unstablePkgs,
        config,
        lib,
        ...
      }:
      {
        services.tailscale = {
          enable = true;
          package = unstablePkgs.tailscale;
          useRoutingFeatures = lib.mkDefault "client";
          openFirewall = true;
        };
        networking.firewall = {
          # Always allow traffic from your Tailscale network
          trustedInterfaces = [ config.services.tailscale.interfaceName ];
        };
      };
    homelab = { unstablePkgs, ... }: {
      services.tsidp = {
        enable = true;
        package = unstablePkgs.tsidp;
        # OIDC providers tend to use their internal resolvers
        settings.enableFunnel = true;

      };
    };
  };
}
