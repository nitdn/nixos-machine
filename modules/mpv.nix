# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.homeManager.pc =
    { pkgs, ... }:
    {
      programs.mpv = {
        enable = true;

        package = pkgs.mpv-unwrapped.wrapper {
          scripts = with pkgs.mpvScripts; [
            uosc
            sponsorblock
          ];

          mpv = pkgs.mpv-unwrapped.override {
            waylandSupport = true;
          };
        };

        config = {
          profile = "high-quality";
          ytdl-format = "bestvideo+bestaudio";
          cache-default = 4000000;
        };
      };
    };
}
