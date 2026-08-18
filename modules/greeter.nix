# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake.modules.nixos = {
    pc = _: {
      services.displayManager.noctalia-greeter.enable = true;
      services.userdbd.silenceHighSystemUsers = true;
    };

  };
}
