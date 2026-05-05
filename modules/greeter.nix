# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos = {
    pc = {
      services.displayManager.gdm = {
        enable = true;
      };

      services.userdbd.silenceHighSystemUsers = true;
    };
  };
}
