# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Baseline for a kakoune wrapper
{ inputs, config, ... }:

let
  inherit (config.flake) wrappers;
in
{
  flake = {
    modules.nixos.pc = { pkgs, ... }: {
      environment.systemPackages = [
        (wrappers.kakoune-pc.wrap { inherit pkgs; })
      ];
      environment.variables = {
        EDITOR = "kak";
        VISUAL = "kak";
      };
    };
    wrappers.kakoune-pc = {
      imports = [ inputs.nix-devshells.wrapperModules.kakoune ];
    };
  };
}
