# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  inherit (config.flake) wrappers;
in
{
  flake.modules.nixos.pc = { pkgs, ... }: {
    environment.systemPackages = [
      (wrappers.kakoune-pc.wrap { inherit pkgs; })
    ];
    environment.variables = {
      EDITOR = "kak";
      VISUAL = "kak";
    };
  };
}
