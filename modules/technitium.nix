# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.modules.nixos.homelab =
    { config, ... }:
    let
      username =
        config.systemd.services.technitium-dns-server.serviceConfig.User or "technitium-dns-server";
    in
    {
      services.technitium-dns-server.enable = true;
      services.postgresql = {
        ensureDatabases = [ username ];
        ensureUsers = [
          {
            name = username;
            ensureDBOwnership = true;
          }
        ];
      };
    };
}
