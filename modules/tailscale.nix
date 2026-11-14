# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
_: {
  flake.modules.nixos = {
    pc = { config, ... }: {
      services.tailscale.enable = true;
      networking.firewall = {
        # Always allow traffic from your Tailscale network
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        # Allow the Tailscale UDP port through the firewall
        allowedUDPPorts = [ config.services.tailscale.port ];
      };
    };
    homelab = _: {
      services.tsidp = {
        enable = true;
        # OIDC providers tend to use their internal resolvers
        settings.enableFunnel = true;

      };
    };
  };
}
