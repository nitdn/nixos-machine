# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos.vps = {
    services.netbird.enable = true;
  };
  flake.modules.nixos.pc = {
    services.netbird.enable = true;
    services.netbird.ui.enable = true;
  };
}
