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
        pkgs.kdePackages.kate # Needed for text editor support
      ];
      environment.variables = {
        EDITOR = "kak";
        VISUAL = "kak";
        PAGER = "kak";
      };
    };
    wrappers.kakoune-pc = {
      imports = [ inputs.nix-devshells.wrapperModules.kakoune ];
    };
  };
}
