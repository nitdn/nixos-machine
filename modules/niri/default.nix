# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  inputs,
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (config.flake) wrappers packages;
  inherit (inputs) home-manager-lib;
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption {
    options.niri = {
      includes = lib.mkOption {
        type = with lib.types; listOf str;
        example = lib.literalExpression ''
          [
            "dms/colors.kdl"
            "dms/layout.kdl"
            "dms/alttab.kdl"
            "dms/binds.kdl"
            "dms/outputs.kdl"
          ]
        '';
        default = [ ];
        description = ''
          Additional non-declarative input paths. Largely meant to be used
          with matugen style generators.
        '';
      };
      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.anything;
          options._children = lib.mkOption {
            type = lib.types.listOf lib.types.anything;
          };
        };
        default = { };
        example = lib.literalExpression ''
          {
            input.mouse.accel-speed = -0.5;
            input.mouse.accel-profile = "flat";
          }
        '';
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

  ;
  config.perSystem =
    {
      pkgs,
      config,
      inputs',
      ...
    }:
    let
      # Define the settings format used for this program
      generator = (import "${home-manager-lib}/modules/lib/generators.nix" { inherit lib; }).toKDL { };
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
        "output \"Microstep MSI G244F BB4H113A00079\"" = {
          transform = "normal";
          mode = "1920x1080";
          variable-refresh-rate = [ ];
        };
        _children = [
          { include = "${./default_binds.kdl}"; }
          { include = "${./default_config.kdl}"; }
          { include = "${./window-rules.kdl}"; }
          { spawn-at-startup = lib.getExe inputs'.zen-browser.packages.default; }
          { spawn-at-startup = "ckb-next"; }
        ];
      };
      packages.niri-unstable = inputs'.niri.packages.default;
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
  config.flake.wrappers.niri-pc =
    {
      wlib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        wlib.wrapperModules.niri
      ];
      options.extraConfigLines = lib.mkOption {
        default = "";
        type = lib.types.lines;
        description = ''
          Escape hatch string option added to the config file for
          options that might not be representable otherwise,
          due to `config.settings` in this module being required to be an attribute set.

          This one is based on Lines instead of strings for extensibility.
        '';
      };

      config = {
        package = packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        extraConfigLines = ''
          include "${./default_binds.kdl}"
          include "${./default_config.kdl}"
          include "${./window-rules.kdl}"
        '';
        settings = {
          extraConfig = config.extraConfigLines;
          spawn-at-startup = [
            (lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
          ];
          environment = {
            QT_QPA_PLATFORMTHEME = "qt6ct";
          };
          input = {
            keyboard = {
              xkb.options = "compose:caps";
            };
            mouse = {
              accel-profile = "flat";
              accel-speed = 0.001;
            };
          };
          layout = {
            gaps = 4;
            border = {
              width = 2;
            };
            focus-ring = {
              width = 2;
            };
          };
          window-rule = [
            {
              geometry-corner-radius = 12;
              clip-to-geometry = true;
              tiled-state = true;
              draw-border-with-background = false;
            }
          ];

          outputs = {
            "Microstep MSI G244F BB4H113A00079" = {
              mode = "1920x1080";
              transform = "normal";
              variable-refresh-rate = _: { };
            };
          };
        };
      };
    };
  config.flake.modules.nixos = {
    pc =
      { pkgs, config, ... }:
      {
        programs.niri.enable = true;
        programs.niri.package = wrappers.niri-pc.wrap { inherit pkgs; };
        environment.systemPackages = lib.mkIf config.programs.niri.enable [
          pkgs.xwayland-satellite
          pkgs.adwaita-icon-theme
          pkgs.wayscriber
        ];
      };
  };
}
