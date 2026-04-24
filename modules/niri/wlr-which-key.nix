# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  lib,
  ...
}:
let
  inherit (config.flake) wrappers;
  wlr-which-key-wrapped =
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
in
{
  flake.wrappers = {
    inherit wlr-which-key-wrapped;
    niri-pc =
      { pkgs, ... }:
      {
        settings = {
          spawn-at-startup = [
            [
              "wayscriber"
              "--daemon"
            ]
          ];
          binds."Mod+W" = _: {
            props.hotkey-overlay-title = "Launch wlr-which-key";
            content.spawn = lib.getExe (wrappers.wlr-which-key-wrapped.wrap { inherit pkgs; });
          };
        };
      };
  };
}
