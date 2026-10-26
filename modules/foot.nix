# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

_: {
  flake = {
    wrappers = {
      foot = { wlib, ... }: {
        imports = [ wlib.wrapperModules.foot ];
        settings = {
          main = {
            include = "~/.config/foot/themes/noctalia";
            font = "monospace:size=14";
            shell = "nu";
          };
          key-bindings.spawn-terminal = "Control+F2";
        };
      };
      niri-pc = _: {
        settings = {
          spawn-at-startup = [ [ "foot" ] ];
          binds."Mod+T".spawn = [ "foot" ];
        };
      };
    };
    modules.nixos.pc = _: {
      wrappers.foot = {
        enable = true;
      };
    };
  };
}
