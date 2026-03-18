# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  lib,
  ...
}:
let
  inherit (config.meta) term;
  inherit (config.flake) wrappers;
  kittyWrapper =
    { wlib, config, ... }:
    let
      kittyKeyValueFormat = config.pkgs.formats.keyValue {
        listsAsDuplicateKeys = true;
        mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
      };
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        settings = lib.mkOption {
          inherit (kittyKeyValueFormat) type;
          default = { };
          description = ''
            Configuration for kitty.
            The fast, feature-rich, GPU based terminal emulator.
          '';
        };

        extraSettings = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = ''
            Extra lines appended to the config file.
            This can be used to maintain order for settings.
          '';
        };
        "kitty.conf" = lib.mkOption {
          type = wlib.types.file config.pkgs;
          default.path =
            let
              fileName = "kitty.conf";
              base = kittyKeyValueFormat.generate fileName config.settings;
            in
            if config.extraSettings != "" then
              config.pkgs.concatText fileName [
                base
                (config.pkgs.writeText "extraSettings" config.extraSettings)
              ]
            else
              base;
          description = ''
            Raw configuration for kitty.
          '';
        };
      };
      config = {
        flags = {
          "--config" = toString config."kitty.conf".path;
        };
        package = config.pkgs.kitty;
      };
    };
in
{
  meta.term = "kitty";

  perSystem.niri.settings = {
    binds."Mod+T".spawn = term;
    "spawn-at-startup \"${term}\"" = { };
  };
  flake = {
    wrappers.kitty-pc = {
      imports = [ kittyWrapper ];
      settings = {
        "map" = "f2 launch --cwd=current --type os-window";
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
        font_size = 14;
        enabled_layouts = "horizontal";
      };
    };
    wrappers.nushell-pc."config.nu".content = ''
      use std/config *

      # Initialize the PWD hook as an empty list if it doesn't exist
      $env.config.hooks.pre_prompt = $env.config.hooks.pre_prompt? | default []

      $env.config.hooks.pre_prompt ++= [{||
        if (which direnv | is-empty) {
          # If direnv isn't installed, do nothing
          return
        }

        direnv export json | from json | default {} | load-env
        # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
        $env.PATH = do (env-conversions).path.from_string $env.PATH
      }]          
      alias y = yazi
    '';
    modules.nixos.pc =
      { pkgs, ... }:
      let
        kittyWrapped = wrappers.kitty-pc.wrap { inherit pkgs; };
      in
      {
        environment.systemPackages = [
          kittyWrapped
          (pkgs.writeShellScriptBin "xterm" ''
            ${term} "$@"
          '')
          pkgs.wl-clipboard
        ];
        # Required for bashInteractive; its gonna be bash anyway
        programs.bash.enable = true;
        programs.direnv.enable = true;
        programs.zoxide = {
          enable = true;
        };
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
      };
    modules.nixos.vps01 =
      { pkgs, ... }:
      {
        # Required for kitty terminfo setup
        environment.systemPackages = [
          pkgs.kitty.terminfo
          pkgs.kitty.shell_integration
        ];
      };
  };
}
