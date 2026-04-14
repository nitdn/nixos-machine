# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  ...
}:
{
  flake.wrappers.wlr-which-key-wrapped =
    {
      wlib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.wlr-which-key ];
      settings.menu = [
        {
          key = "s";
          desc = "Annotate screen";
          cmd = "pkill -SIGUSR1 wayscriber";
        }
        {
          key = "n";
          desc = "Toggle Notifications";
          cmd = "dms ipc call notifications toggle";
        }
        {
          key = "d";
          desc = "Toggle dashboard";
          cmd = "dms ipc call dash toggle overview";
        }
        {
          key = "l";
          desc = "Open logseq";
          cmd = "logseq";
        }
        {
          key = "f";
          desc = "Toggle window floating";
          cmd = "niri msg action toggle-window-floating";
        }
        {
          key = "v";
          desc = "Turn off VRR (if the manure hits the sediment)";
          cmd = ''niri msg output "Microstep MSI G244F BB4H113A00079" vrr off'';
        }
        {
          key = "t";
          desc = "Set dynamic cast window";
          cmd = "niri msg action set-dynamic-cast-window";
        }
      ];
    };
  perSystem =
    { config, ... }:
    {
      niri.settings = {
        _children = [
          {
            spawn-at-startup = [
              "wayscriber"
              "--daemon"
            ];
          }
        ];
        binds."Mod+W".spawn = lib.getExe config.packages.wlr-which-key-wrapped;
      };
    };
}
