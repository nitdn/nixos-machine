# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.wrappers.wlr-which-key-wrapped.settings.menu = [
    {
      key = "n";
      desc = "Toggle Notifications";
      cmd = "noctalia msg panel-toggle control-center notifications";
    }
    {
      key = "c";
      desc = "Toggle Calendar";
      cmd = "noctalia msg panel-toggle  control-center calendar";
    }
    {
      key = "v";
      desc = "Toggle Clipboard";
      cmd = "noctalia msg panel-toggle clipboard";
    }
  ];
}
