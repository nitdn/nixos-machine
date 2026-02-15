# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
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
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    options.niri = {
      includes = lib.mkOption {
        type = with lib.types; listOf str;
        example = [
          "dms/colors.kdl"
          "dms/layout.kdl"
          "dms/alttab.kdl"
          "dms/binds.kdl"
          "dms/outputs.kdl"
        ];
        default = [ ];
        description = ''
          Additional non-declarative input paths. Largely meant to be used
          with matugen style generators.
        '';
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = { };
        example = {
          input.mouse.accel-speed = -0.5;
          input.mouse.accel-profile = "flat";
        };
        description = ''
          Niri configuration in nix format. This uses the home-manager
          KDL generator.
          NOTE 1: KDL decided that it will allow repeating of non-nested
          nodes. Nix doesnt have any sane way of representing them so instead
          you should try to create a long attribute (```"spawn-at-startup \"foo\"" = {};
          "spawn-at-startup \"bar\"" = {}```) to work around this limitation.
          You can also use `_children` sometimes.
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
              accel-speed -0.5
              accel-profile flat
            }
          }
        '';
        default = "";
        description = ''
          Niri configuration in raw KDL format. This will be `include`d in
          the final config file.

          WARNING: Nested nodes CANNOT be repeated! Thats the only thing about KDL
          that cannot be repeated for some reason. This option has no merging
          of nodes.'';
      };
    };
  }

  );
  config.perSystem =
    { pkgs, config, ... }:
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
      niri.settings = {
        input.mouse.accel-speed = lib.mkDefault 0.001;
        input.mouse.accel-profile = "flat";
        input.keyboard.xkb.options = "compose:caps";
        "output \"DP-2\"" = {
          transform = "normal";
          mode = "1920x1080";
        };
        _children = [
          { include = "${./default_binds.kdl}"; }
          { include = "${./default_config.kdl}"; }
          { include = "${./window-rules.kdl}"; }
          { spawn-at-startup = "zen-beta"; }
          { spawn-at-startup = "ckb-next"; }
        ];
      };
      packages.niri-config = pkgs.writeTextFile {
        name = "niri-config";
        text = finalNiriConfig;
        checkPhase = ''
          TMPFILE=$(mktemp)
          cat << EOF > "$TMPFILE"
          ${niriConfigWithoutIncludes}
          EOF
          cat "$TMPFILE"
          ${pkgs.niri}/bin/niri validate -c "$TMPFILE"
        '';
      };
    };
  config.flake.modules.nixos.pc = moduleWithSystem (
    { config, pkgs, ... }:
    {
      programs.niri.enable = true;
      environment.systemPackages = [
        pkgs.xwayland-satellite
      ];
      systemd.user.tmpfiles.rules = [
        "L+ %h/.config/niri/config.kdl - - - - ${config.packages.niri-config}"
      ];
    }

  );
}
