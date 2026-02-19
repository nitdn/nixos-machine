# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  lib,
  flake-parts-lib,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    let
      # Define the settings format used for this program
      settingsFormat = pkgs.formats.yaml { };
      inherit (inputs) wrappers;
      wlr-which-key-wrapped = wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.wlr-which-key;
        args = [
          (settingsFormat.generate "wlr-config.yaml" config.wlr-which-key.settings)
        ];
      };
    in
    {
      options.wlr-which-key = {
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
      };
      config.packages = { inherit wlr-which-key-wrapped; };
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
