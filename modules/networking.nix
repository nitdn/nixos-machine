# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    let
      tls_auth_name = "dns.adguard-dns.com";
    in
    {
      networking.domain = "home.arpa";
      networking.dhcpcd.wait = "background";
      services.stubby = {
        enable = true;
        settings = pkgs.stubby.passthru.settingsExample // {
          upstream_recursive_servers = [
            {
              address_data = "94.140.14.14";
              inherit tls_auth_name;
            }
            {
              address_data = "2a10:50c0::ad1:ff";
              inherit tls_auth_name;
            }
          ];
        };
      };
    };
}
