# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  lib,
  flake-parts-lib,
  moduleWithSystem,
  ...
}:

{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    let
      # Define the settings format used for this program
      generator = inputs.home-manager.lib.hm.generators.toKDL { };
      niriConfigWithoutIncludes =
        (generator config.niri.settings)
        + ''include "${pkgs.writeText "niri-extraConfig" config.niri.extraConfig}"'';
      finalNiriConfig = lib.strings.concatLines (
        [ niriConfigWithoutIncludes ] ++ lib.lists.forEach config.niri.includes (s: ''include "${s}"'')
      );
    in
    {
      options = {
        niri = {
          includes = lib.mkOption {
            type = with lib.types; listOf str;
            example = [
              "dms/colors.kdl"
              "dms/layout.kdl"
              "dms/alttab.kdl"
              "dms/binds.kdl"
            ];
            default = [ ];
            description = ''
              Additional non-declarative input paths. Largely meant to be used
              with matugen style generators.
            '';
          };
          settings = lib.mkOption {
            type = with lib.types; lazyAttrsOf anything;
            default = { };
            example = {
              input.mouse.accel-speed = -0.7;
              input.mouse.accel-profile = "flat";
            };

            description = ''
              Niri configuration in nix format. This uses the home-manager
              KDL generator.
              NOTE 1: KDL decided that it will allow repeating of non-nested
              nodes. Nix doesnt have any sane way of representing them so instead
              you should try to create a long attribute (```"spawn-at-startup \"foo\"" = {};
              "spawn-at-startup \"bar\"" = {}```) to work around this limitation.
              NOTE 2: that some options may need to be flattened with
              `_args` for multi-argument arrays and `_props` for properties
              (not kdl nodes).
            '';
          };
          extraConfig = lib.mkOption {
            type = lib.types.lines;
            example = ''
              input {
                mouse {
                  accel-speed -0.7
                  accel-profile flat
                }
              }
            '';
            description = ''
              Niri configuration in raw KDL format. This will be `include`d in
              the final config file.

              WARNING: Nested nodes CANNOT be repeated! Thats the only thing about KDL
              that cannot be repeated for some reason. This option has no merging
              of nodes.'';
          };
        };
      };
      config.niri.settings = {
        input.mouse.accel-speed = -0.7;
        input.mouse.accel-profile = "flat";
        input.keyboard.xkb.options = "compose:caps";
        "spawn-at-startup \"zen-beta\"" = { };
      };
      config.niri.extraConfig = lib.readFile ./niri.kdl;
      config.packages.niri-config = pkgs.writeTextFile {
        name = "niri-config";
        text = finalNiriConfig;
        checkPhase = ''
          TMPFILE=$(mktemp)
          cat << EOF > "$TMPFILE"
          ${niriConfigWithoutIncludes}
          EOF
          ${pkgs.niri}/bin/niri validate -c "$TMPFILE"
        '';
      };
      config.packages.niri-wrapped =
        (inputs.wrappers.wrapperModules.niri.apply {
          inherit pkgs;
          "config.kdl".path = config.packages.niri-config;
        }).wrapper;
    }
  );
  config.flake.modules.nixos.pc = moduleWithSystem (
    { config, pkgs, ... }:
    {
      config = {
        programs.niri.enable = true;
        programs.niri.package = config.packages.niri-wrapped;
        environment.systemPackages = [
          pkgs.wl-clipboard
          pkgs.cliphist
          pkgs.xwayland-satellite
        ];
      };
    }
  );
}
