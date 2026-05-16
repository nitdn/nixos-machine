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
      key = "s";
      desc = "Toggle Calendar";
      cmd = "noctalia-shell ipc call calendar toggle";
    }
    {
      key = "v";
      desc = "Toggle Clipboard";
      cmd = "noctalia-shell ipc call launcher clipboard";
    }
  ];
}
