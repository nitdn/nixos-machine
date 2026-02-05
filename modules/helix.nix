# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{ config, ... }:
let
  flakeModules = config.flake.modules;
in
{
  flake.modules.homeManager.helix =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.helix = {
        enable = true;
        defaultEditor = true;
        extraPackages = [
          pkgs.nixd
          pkgs.taplo
          pkgs.yaml-language-server
        ];

        settings = {
          theme = lib.mkDefault "catppuccin_mocha";
          editor = {
            end-of-line-diagnostics = "hint";
            inline-diagnostics.cursor-line = "warning";
            # lsp.display-inlay-hints = true;
          };
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          keys = {
            normal = {
              tab = "move_parent_node_end";
              S-tab = "move_parent_node_start";
            };
            select = {
              tab = "extend_parent_node_end";
              S-tab = "extend_parent_node_start";

            };
          };
        };
        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.nixfmt;

          }
          {
            name = "yaml";
            auto-format = true;
            formatter.command = lib.getExe pkgs.dprint;
            formatter.args = [
              "fmt"
              "--stdin"
              "yaml"
            ];
          }
        ];
        # YAML config
        languages.language-server.yaml-language-server.config.yaml = {
          format = {
            enable = true;
          };
          validation = true;
        };
      };
    };
  flake.modules.homeManager.pc = {
    imports = [ flakeModules.homeManager.helix ];
    # stylix.targets.helix.enable = false;
  };
  flake.modules.homeManager.droid = {
    imports = [ config.flake.modules.homeManager.helix ];
  };
}
