# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.modules.nixos = {
    pc =
      { pkgs, ... }:
      {
        services.kmscon = {
          enable = true;
          config.font-name = "JetBrains Mono";
          config.hwaccel = true;
        };
        services.greetd = {
          enable = true;
          useTextGreeter = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember";
              user = "greeter";
            };
          };
        };
        services.userdbd.silenceHighSystemUsers = true;
      };
  };
}
