# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (inputs) wrappers;
  wlr-wrapper =
    { config, wlib, ... }:
    let
      settingsFormat = config.pkgs.formats.yaml { };
    in
    {
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
      config.args = [
        "${config.configFile.path}"
      ];
    };
  staticModules = [
    wlr-wrapper
    "${wrappers}/lib/modules/wrapper.nix"
    "${wrappers}/lib/modules/meta.nix"
  ];
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      # Define the settings format used for this program
      inherit (lib.types) attrsOf deferredModuleWith;
      inherit (config.packages) wlr-which-key-wrapped;
    in
    {
      options.wrappers.wlr-which-key = lib.mkOption {
        description = "wlr-which-key wrapper options";
        type = attrsOf (deferredModuleWith {
          inherit staticModules;
        });
      };
      config.wrappers.wlr-which-key.wrapped.imports = [ ];
      config.niri.settings = {
        _children = [
          {
            spawn-at-startup = [
              "wayscriber"
              "--daemon"
            ];
          }
        ];
        binds."Mod+W".spawn = lib.getExe wlr-which-key-wrapped;
      };
    }
  );
}
