# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake = {
    wrappers = {
      ghostty = { wlib, ... }: {
        imports = [ wlib.wrapperModules.ghostty ];
        settings = {
          theme = "noctalia";
          font-family = "Iosevka Extended";
          font-size = 14;
          command = "nu";
          background-opacity = 0.75;
          background-blur = true;
          keybind = [
            "ctrl+f2=new_window"
          ];
        };
      };
      niri-pc = _: {
        settings = {
          spawn-at-startup = [ [ "ghostty" ] ];
          binds."Mod+T".spawn = [ "ghostty" ];
        };
      };
    };
    modules.nixos.pc = _: {
      wrappers.ghostty.enable = true;
    };
  };
}
