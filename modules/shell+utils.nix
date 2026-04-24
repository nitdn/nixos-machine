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
      importsGeneratorArgs = {
        mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
        listsAsDuplicateKeys = true;
      };
      importsType = config.pkgs.formats.keyValue importsGeneratorArgs;
      importsGenerate = lib.generators.toKeyValue importsGeneratorArgs;
    in
    {
      imports = [ wlib.wrapperModules.kitty ];
      options.extraSettings = lib.mkOption {
        inherit (importsType) type;
        default = { };
        description = ''
          Extra settings for kitty that may not be
          encoded by the wrapper correctly'';
      };
      config.extraConfig = importsGenerate config.extraSettings;
    };
in
{
  meta.term = "kitty";
  flake = {
    wrappers = {
      kitty-pc = {
        imports = [ kittyWrapper ];
        font.name = "monospace";
        font.size = 14;
        keybindings = {
          f2 = "launch --cwd=current --type os-window";
        };
        settings = {
          scrollback_lines = 10000;
          enable_audio_bell = false;
          update_check_interval = 0;
          enabled_layouts = "horizontal";
        };
      };
      niri-pc.settings = {
        spawn-at-startup = [ [ term ] ];
        binds."Mod+T".spawn = [ term ];
      };
      nushell-pc."config.nu".content = ''
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
    };
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
        fonts.fontconfig.localConf = /* xml */ ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <match target="scan">
              <test name="family">
                <string>Noto Sans Mono</string>
              </test>
              <edit name="spacing">
                <int>100</int>
              </edit>
            </match>
          </fontconfig>
        '';
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
