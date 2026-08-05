# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  # inputs,
  config,
  lib,
  ...
}:
let
  inherit (config.flake) wrappers;
in
{
  flake.wrappers = {
    noctalia-v5 =
      {
        wlib,
        pkgs,
        config,
        ...
      }:
      {
        imports = [ wlib.modules.default ];
        env.NOCTALIA_CONFIG_HOME = "${placeholder "out"}/config";
        passthru.tests.config-is-correct = pkgs.testers.runCommand {
          name = "noctalia-config";
          nativeBuildInputs = [ (config.wrap { }) ];
          script = ''
            noctalia config validate
            noctalia config export
            touch $out
          '';
        };
        package = pkgs.noctalia;
        runtimePkgs = [
          pkgs.ddcutil
        ];
        constructFiles.generatedConfig = {
          content = lib.readFile ./noctalia-config.toml;
          relPath = "config/noctalia/config.toml";
        };
      };
    niri-pc =
      { pkgs, config, ... }:
      let
        noctaliaExe = lib.getExe' config.noctaliaPackage "noctalia";
      in
      {
        options.noctaliaPackage = lib.mkPackageOption pkgs "noctalia" { };
        config = {

          noctaliaPackage = lib.mkDefault (wrappers.noctalia-v5.wrap { inherit pkgs; });
          extraSettings = [
            {
              include = [
                { optional = true; }
                "~/.config/niri/noctalia.kdl"
              ];
            }
          ];
          settings = {
            spawn-at-startup = [
              noctaliaExe
              # [
              #   "valent"
              #   "--gapplication-service"
              # ]
            ];
            binds."Mod+Space" = _: {
              props = {
                hotkey-overlay-title = "Toggle launcher";
              };
              content.spawn = [
                noctaliaExe
                "msg"
                "panel-toggle"
                "launcher"
              ];
            };
            binds."Mod+E" = _: {
              props = {
                hotkey-overlay-title = "Toggle Calendar/Clock";
              };
              content.spawn = [
                noctaliaExe
                "msg"
                "panel-toggle"
                "control-center"
                "calendar"
              ];
            };
            binds."Mod+Delete" = _: {
              props = {
                hotkey-overlay-title = "Toggle logout menu";
              };
              content.spawn = [
                noctaliaExe
                "msg"
                "panel-toggle"
                "session"
              ];
            };

            layer-rules = [
              {
                matches = [ { namespace = "^noctalia-wallpaper*"; } ];
                place-within-backdrop = true;
              }
            ];

            debug = {
              honor-xdg-activation-with-invalid-serial = _: { };
            };

            layout = {
              background-color = "transparent";
            };

            overview = {
              workspace-shadow.off = _: { };
            };
          };
        };
      };
    kitty-pc = {
      extraSettings.include = [ "~/.config/kitty/themes/noctalia.conf" ];
    };
  };
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.wtype
        (wrappers.noctalia-v5.wrap { inherit pkgs; })
      ];
    };
}
