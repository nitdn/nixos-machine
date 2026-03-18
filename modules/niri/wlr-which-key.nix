# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  ...
}:
let
  wlr-wrapper =
    { config, wlib, ... }:
    let
      settingsFormat = config.pkgs.formats.yaml { };
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        settings = lib.mkOption {
          # Setting this type allows for correct merging behavior
          inherit (settingsFormat) type;
          default = {
            menu = [
              {
                key = "s";
                desc = "Annotate screen";
                cmd = "pkill -SIGUSR1 wayscriber";
              }
            ];
          };
          description = ''
            Settings for wlr-which-key. See
            https://github.com/MaxVerevkin/wlr-which-key?tab=readme-ov-file#configuration
            for more information.
          '';
        };
        configFile = lib.mkOption {
          type = wlib.types.file config.pkgs;
          default.path = settingsFormat.generate "wlr-config.yaml" config.settings;
        };
      };
      config.package = config.pkgs.wlr-which-key;
      config.addFlag = [
        config.configFile.path
      ];
    };
in
{
  flake.wrappers.wlr-which-key-wrapped.imports = [ wlr-wrapper ];
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
