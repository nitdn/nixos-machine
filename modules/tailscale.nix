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
    homelab =
      {
        unstablePkgs,
        config,
        lib,
        ...
      }:
      let
        cfg = config.tailscale.vips;
        isV6 = lib.hasInfix ":";
      in
      {
        options.tailscale.vips = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Tailscale Service VIPs (v4 and/or v6) to assign to lo.";
        };
        config.networking.interfaces.lo = {
          ipv4.addresses = map (a: {
            address = a;
            prefixLength = 32;
          }) (lib.filter (a: !isV6 a) cfg);
          ipv6.addresses = map (a: {
            address = a;
            prefixLength = 128;
          }) (lib.filter isV6 cfg);
        };
        config.services.tailscale.useRoutingFeatures = "server";
        config.services.tsidp = {
          enable = true;
          package = unstablePkgs.tsidp;
          # OIDC providers tend to use their internal resolvers
          settings.enableFunnel = true;

        };
      };
  };
}
