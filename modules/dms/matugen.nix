# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  lib,
  getSystem,
  ...
}:

let
  inherit (config.meta) username;
in
{
  flake = {
    modules.nixos.dms =
      { pkgs, ... }:
      let
        inherit (pkgs.stdenv.hostPlatform) system;
        perSystem = getSystem system;
        inherit (perSystem.nvfetched) matugen-themes;
        matugenThemes = "${matugen-themes.src}/templates";
        matugen.config = { };
        matugen.templates.helix = {
          input_path = "${matugenThemes}/helix.toml";
          output_path = "/home/${username}/.config/helix/themes/matugen.toml";
        };
        matugen.templates.zathura = {
          input_path = "${matugenThemes}/zathura-colors";
          output_path = "/home/${username}/.config/zathura/zathurarc";
        };
        matugenTemplate = (pkgs.formats.toml { }).generate "matugen/config.toml" matugen;
      in

      {
        houses.users = {
          ${username}.files = [
            {
              type = "symlink";
              source = matugenTemplate;
              target = ".config/matugen/config.toml";
            }
          ];
        };
      };
    wrappers = {
      helix-pc.settings.theme = "matugen_dark";
      helix-work.settings.theme = lib.mkForce "matugen_light";
      helix-pc.themes = {
        matugen_dark = lib.readFile ./helix/matugen_dark.toml;
        matugen_light = lib.readFile ./helix/matugen_light.toml;
      };

      kitty-pc.settings.include = lib.map (dmsPath: "/home/${username}/.config/kitty/${dmsPath}") [
        "dank-tabs.conf"
        "dank-theme.conf"
      ];
    };
  };

}
