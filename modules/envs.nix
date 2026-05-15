# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (config.meta) username;
in

{
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      security.sudo.extraRules = [
        {
          users = [ username ];
          commands = [ "ALL" ];
        }
      ];
      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = [
        #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        #  wget
        pkgs.dust
        pkgs.git
        pkgs.gparted
        pkgs.ldns # drill
        pkgs.openssl
        pkgs.pwgen
        pkgs.ripgrep
        pkgs.trash-cli
        (lib.lowPrio inputs.eh.packages.${pkgs.stdenv.hostPlatform.system}.default)
        (pkgs.writeShellApplication {
          name = "ns";
          runtimeInputs = with pkgs; [
            fzf
            nix-search-tv
          ];
          text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
        })
      ];
      environment.variables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };
    };
}
