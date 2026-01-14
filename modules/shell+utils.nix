# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  moduleWithSystem,
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  homeModules = config.flake.modules.homeManager;
  inherit (config.meta) term;
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    options.wrappers.kitty = lib.mkOption {
      description = "Kitty config from lassulus/wrappers";
      type = lib.types.submoduleWith {
        modules = [
          "${inputs.wrappers}/modules/kitty/module.nix"
          "${inputs.wrappers}/lib/modules/wrapper.nix"
          "${inputs.wrappers}/lib/modules/meta.nix"

        ];
        specialArgs = {
          wlib = inputs.wrappers.lib;
        };
      };
    };
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
        wrappers.kitty = {
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
        packages.kittyWrapped = config.wrappers.kitty.wrapper;
      };
    flake.modules.homeManager.shells = moduleWithSystem (
      {
        pkgs,
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
          (pkgs.writeShellScriptBin "xterm" ''
            ${term} "$@"
          '')

        ];

        home.sessionVariables.TERMINAL = term;

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
    flake.modules.nixos.pc = moduleWithSystem (
      { config, ... }:
      {
        environment.systemPackages = [ config.packages.kittyWrapped ];
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
