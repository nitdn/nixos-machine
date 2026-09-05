# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, ... }: {
  flake.wrappers = { inherit (inputs.wrappers.lib.wrapperModules) mpv; };
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      wrappers.mpv = {
        enable = true;
        script = {
          uosc.path = pkgs.mpvScripts.uosc;
          sponsorblock.path = pkgs.mpvScripts.sponsorblock;
        };
        "mpv.conf".content = ''
          vo=gpu
          hwdec=auto
        '';
        "mpv.input".content = ''
          WHEEL_UP seek 10
          WHEEL_DOWN seek -10
        '';
      };
    };
}
