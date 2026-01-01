# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  moduleWithSystem,
  config,
  lib,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  inherit (config.meta) term;
in
{
  meta.term = "kitty";
  perSystem =

    {
      niri.settings = {
        binds."Mod+T".spawn = term;
        "spawn-at-startup \"${term}\"" = { };
      };
    };
  flake.modules.homeManager.shells = moduleWithSystem (
    {
      pkgs,
      inputs',
      ...
    }:
    {
      programs.eza = {
        enable = true;
      };

      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        shellWrapperName = "y";

        settings = {
          manager = {
            show_hidden = true;
          };
          preview = {
            max_width = 1000;
            max_height = 1000;
          };
        };
      };
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home.packages = [
        inputs'.direnv-instant.packages.default
        (pkgs.writeShellScriptBin "xterm" ''
          ${term} "$@"
        '')

      ];
      programs.kitty = {
        enable = true;
        keybindings = {
          "f2" = "launch --cwd=current --type os-window";
        };
        settings = {
          scrollback_lines = 10000;
          enable_audio_bell = false;
          update_check_interval = 0;
          font_size = 14;
          enabled_layouts = "horizontal";
        };
      };

      home.sessionVariables.TERMINAL = term;

      programs.starship = {
        enable = true;
      };
      xdg.configFile."starship.toml".source = lib.mkForce inputs."jetpack.toml";

      programs.fzf = {
        enable = true;
      };
      programs.zoxide = {
        enable = true;
      };
      programs.bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          batwatch
          batpipe
        ];
      };
      programs.btop.enable = true;
    }
  );
  flake.modules.homeManager = {
    pc.imports = [ homeModules.shells ];
    droid.imports = [ homeModules.shells ];
  };
  flake.modules.nixos.vps01 =
    { pkgs, ... }:
    {
      # Required for kitty terminfo setup
      environment.systemPackages = with pkgs.kitty; [
        terminfo
        shell_integration
      ];
    };
}
