# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  ...
}:
let
  wlr-wrapper =
    {
      config,
      wlib,
      ...
    }:
    let
      settingsFormat = config.pkgs.formats.yaml { };
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        settings = lib.mkOption {
          # Setting this type allows for correct merging behavior
          inherit (settingsFormat) type;
          default = { };
          description = ''
            Settings for wlr-which-key. See
            https://github.com/MaxVerevkin/wlr-which-key?tab=readme-ov-file#configuration
            for more information.
          '';
        };
        configFile = lib.mkOption {
          type = wlib.types.file config.pkgs;
          default.path = config.constructFiles.generatedConfig.path;
          # default.path = settingsFormat.generate "wlr-config.yaml" config.settings;
        };
      };
      config.package = config.pkgs.wlr-which-key;
      config.constructFiles.generatedConfig = {
        content = lib.generators.toYAML { } config.settings;
        relPath = "${config.binName}-config.yaml";
      };
      config.addFlag = [
        config.configFile.path
      ];
    };
in
{
  flake.wrappers.wlr-which-key-wrapped = {
    imports = [ wlr-wrapper ];
    settings.menu = [
      {
        key = "s";
        desc = "Annotate screen";
        cmd = "pkill -SIGUSR1 wayscriber";
      }
      {
        key = "n";
        desc = "Toggle Notifications";
        cmd = "dms ipc call notifications toggle";
      }
      {
        key = "d";
        desc = "Toggle dashboard";
        cmd = "dms ipc call dash toggle overview";
      }
      {
        key = "l";
        desc = "Open logseq";
        cmd = "logseq";
      }
      {
        key = "f";
        desc = "Toggle window floating";
        cmd = "niri msg action toggle-window-floating";
      }
      {
        key = "v";
        desc = "Turn off VRR (if the manure hits the sediment)";
        cmd = ''niri msg output "Microstep MSI G244F BB4H113A00079" vrr off'';
      }
      {
        key = "t";
        desc = "Set dynamic cast window";
        cmd = "niri msg action set-dynamic-cast-window";
      }
    ];
  };
  perSystem =
    { config, ... }:
    {
      niri.settings = {
        _children = [
          {
            spawn-at-startup = [
              "wayscriber"
              "--daemon"
            ];
          }
        ];
        binds."Mod+W".spawn = lib.getExe config.packages.wlr-which-key-wrapped;
      };
    };
}
