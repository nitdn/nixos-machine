# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  moduleWithSystem,
  config,
  flake-parts-lib,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  inherit (config.meta) term;
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    # options.wrappers.kitty.pc
    #  = lib.mkOption {
    #   description = "Kitty config from lassulus/wrappers";
    #   type = lib.types.submoduleWith {
    #     modules = [
    #       "${inputs.wrappers}/modules/kitty/module.nix"
    #       "${inputs.wrappers}/lib/modules/wrapper.nix"
    #       "${inputs.wrappers}/lib/modules/meta.nix"

    #     ];
    #     specialArgs = {
    #       wlib = inputs.wrappers.lib;
    #     };
    #   };
    # };
  });
  config = {
    meta.term = "kitty";
    perSystem =
      { pkgs, config, ... }:

      {
        niri.settings = {
          binds."Mod+T".spawn = term;
          "spawn-at-startup \"${term}\"" = { };
        };
        wrappers.kitty.pc = {
          inherit pkgs;
          settings = {
            "map" = "f2 launch --cwd=current --type os-window";
            scrollback_lines = 10000;
            enable_audio_bell = false;
            update_check_interval = 0;
            font_size = 14;
            enabled_layouts = "horizontal";
          };
        };
        wrappers.nushell.pc.extraConfig = ''
          use std/config *

          # Initialize the PWD hook as an empty list if it doesn't exist
          $env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

          $env.config.hooks.env_change.PWD ++= [{||
            if (which direnv | is-empty) {
              # If direnv isn't installed, do nothing
              return
            }

            direnv export json | from json | default {} | load-env
            # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
            $env.PATH = do (env-conversions).path.from_string $env.PATH
          }]          
        '';
        packages.kittyWrapped = config.wrappers.kitty.pc.wrapper;
      };
    flake.modules.homeManager.shells = {
      home.sessionVariables.TERMINAL = term;
    };
    flake.modules.homeManager = {
      pc.imports = [ homeModules.shells ];
      droid.imports = [ homeModules.shells ];
    };
    flake.modules.nixos.pc = moduleWithSystem (
      { config, pkgs, ... }:
      {
        environment.systemPackages = [
          config.packages.kittyWrapped
          (pkgs.writeShellScriptBin "xterm" ''
            ${term} "$@"
          '')
        ];
        programs.direnv.enable = true;
        programs.zoxide.enable = true;
        programs.yazi = {
          enable = true;

          settings.yazi = {
            manager = {
              show_hidden = true;
            };
            preview = {
              max_width = 1000;
              max_height = 1000;
            };
          };
        };
      }
    );
    flake.modules.nixos.vps01 =
      { pkgs, ... }:
      {
        # Required for kitty terminfo setup
        environment.systemPackages = with pkgs.kitty; [
          terminfo
          shell_integration
        ];
      };
  };
}
