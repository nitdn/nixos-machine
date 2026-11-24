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
        networking.nftables.enable = true;
        networking.firewall = {
          enable = true;
          # Always allow traffic from your Tailscale network
          trustedInterfaces = [ config.services.tailscale.interfaceName ];
          # Allow the Tailscale UDP port through the firewall
          allowedUDPPorts = [ config.services.tailscale.port ];
        };

        # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
        # This avoids the "iptables-compat" translation layer issues.
        systemd.services.tailscaled.serviceConfig.Environment = [
          "TS_DEBUG_FIREWALL_MODE=nftables"
        ];

      };
    homelab = { unstablePkgs, ... }: {
      services.tailscale.useRoutingFeatures = "server";
      services.tsidp = {
        enable = true;
        package = unstablePkgs.tsidp;
        # OIDC providers tend to use their internal resolvers
        settings.enableFunnel = true;

      };
    };
  };
}
