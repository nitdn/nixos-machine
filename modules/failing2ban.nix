# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.vps = {
    services.fail2ban = {
      enable = true;
    };
  };
}
