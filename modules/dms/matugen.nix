# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config.meta) username;
  inherit (inputs) matugen-themes;

in
{
  flake = {
    modules.nixos.dms =
      { pkgs, ... }:
      let
        matugenThemes = "${matugen-themes}/templates";
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
        systemd.user.services.dms.serviceConfig = {
          BindPaths = [ "${matugenTemplate}:%E/matugen/config.toml" ];
        };
      };
    wrappers = {
      helix-pc.settings.theme = "matugen_dark";
      helix-work.settings.theme = lib.mkForce "matugen_light";
      helix-pc.themes = {
        matugen_dark = lib.readFile ./helix/matugen_dark.toml;
        matugen_light = lib.readFile ./helix/matugen_light.toml;
      };

      kitty-pc.extraSettings.include = lib.map (dmsPath: "/home/${username}/.config/kitty/${dmsPath}") [
        "dank-tabs.conf"
        "dank-theme.conf"
      ];
    };
  };

}
