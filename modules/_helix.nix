# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  lib,
  config,
  ...
}:
let
  inherit (config.flake) wrappers;
  helix-pc =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.helix ];
      settings = {
        theme = lib.mkDefault "ashen";
        editor = {
          line-number = "relative";
          # end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "warning";
          # lsp.display-inlay-hints = true;
        };
        editor.statusline = {
          center = [
            "file-type"
            "primary-selection-length"
            "total-line-numbers"
          ];
        };
        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
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
            C-j = [
              "extend_to_line_bounds"
              "delete_selection"
              "move_line_down"
              "paste_before"
              "select_mode"
            ];
            C-k = [
              "extend_to_line_bounds"
              "delete_selection"
              "move_line_up"
              "paste_before"
              "select_mode"
            ];
          };
        };
      };
      languages = {
        language-server = {
          uwu_colors.command = "${pkgs.uwu-colors}/bin/uwu_colors";
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nixd"
            ];
          }
          {
            name = "yaml";
            formatter = {
              command = lib.getExe pkgs.prettier;
              args = [
                "--parser"
                "yaml"
              ];
            };
          }
        ];
      };
      runtimePkgs = [

        pkgs.git
        pkgs.nixd
        pkgs.nixfmt
        pkgs.nushell
        pkgs.prettier
        pkgs.stdenv.cc
      ];
    };
  helix-light = {
    imports = [ config.flake.wrapperModules.helix-pc ];
    settings.theme = "ingrid";
  };
in
{
  flake.wrappers = { inherit helix-pc helix-light; };
  flake.modules.nixos.darkMode =
    {
      pkgs,
      ...
    }:
    {
      config.environment.systemPackages = [
        (wrappers.helix-pc.wrap { inherit pkgs; })

      ];
    };
  flake.modules.nixos.lightMode =
    {
      pkgs,
      ...
    }:
    {
      config.environment.systemPackages = [
        (wrappers.helix-light.wrap { inherit pkgs; })
      ];
    };
}
