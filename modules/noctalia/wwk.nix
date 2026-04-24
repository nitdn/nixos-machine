# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.wrappers.wlr-which-key-wrapped.settings.menu = [
    {
      key = "n";
      desc = "Toggle Notifications";
      cmd = "noctalia-shell ipc call notifications toggleHistory";
    }
    {
      key = "d";
      desc = "Toggle Control Center";
      cmd = "noctalia-shell ipc call controlCenter toggle";
    }

  ];
}
