# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos = {
    pc = _: {
      services.kmscon = {
        enable = true;
        config.font-name = "JetBrains Mono";
        config.hwaccel = true;
      };
      services.displayManager.plasma-login-manager = {
        enable = true;
        settings = {
          Greeter.PreSelectedUser = username;
        };
      };
      services.userdbd.silenceHighSystemUsers = true;
    };

  };
}
