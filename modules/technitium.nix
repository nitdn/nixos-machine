# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.modules.nixos.homelab =
    _:
    {
      services.technitium-dns-server.enable = true;
    };
}
