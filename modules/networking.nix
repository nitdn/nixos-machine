# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.pc =
    let
      tls_auth_name = "jmfa1wa82x.cloudflare-gateway.com";
      v4_address = "172.64.36.1";
      v6_address = "2a06:98c1:54::c2e2";
    in
    {
      networking.domain = "home.arpa";
      networking.dhcpcd.wait = "background";
      services.stubby = {
        enable = true;
        settings = {
          dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
          edns_client_subnet_private = 1;
          idle_timeout = 10000;
          listen_addresses = [
            "127.0.0.1"
            "0::1"
          ];
          log_level = "GETDNS_LOG_NOTICE";
          resolution_type = "GETDNS_RESOLUTION_STUB";
          round_robin_upstreams = 1;
          tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
          tls_query_padding_blocksize = 128;
          upstream_recursive_servers = [
            {
              address_data = v4_address;
              inherit tls_auth_name;
            }
            {
              address_data = v6_address;
              inherit tls_auth_name;
            }
          ];
        };
      };
    };
}
