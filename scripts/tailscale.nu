# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let services = [
  [service, protocol, port];
  [cache, https=443, 8080]
  [freshrss, tcp=443, 443]
  [status, https=443, 8090]
  [tcdns, https=443, 5380]
  [garage, tun, ""]
]

{} | save --append /tmp/empty.json

tailscale serve set-config --all /tmp/empty.json

rm /tmp/empty.json

$services | each {|| tailscale serve --service svc:($in.service) --($in.protocol) localhost:($in.port)  }
