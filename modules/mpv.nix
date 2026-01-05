# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ inputs, ... }:
{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (inputs.wrappers.wrapperModules.mpv.apply {
          inherit pkgs;
          scripts = with pkgs.mpvScripts; [
            uosc
            sponsorblock
          ];
          "mpv.conf".content = ''
            vo=gpu
            hwdec=auto
          '';
          "mpv.input".content = ''
            WHEEL_UP seek 10
            WHEEL_DOWN seek -10
          '';
        }).wrapper
      ];
    };
}
