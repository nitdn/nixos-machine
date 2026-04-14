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
  nixosModules = config.flake.modules.nixos;
  helix-pc =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.helix ];
      settings = {
        theme = lib.mkDefault "catppuccin_mocha";
        editor = {
          line-number = "relative";
          end-of-line-diagnostics = "hint";
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
      languages.language = [
        {
          name = "nix";
          auto-format = true;
        }
      ];
      extraPackages = [
        pkgs.nixd
        pkgs.nil
      ];
    };
  helix-work = {
    imports = [ config.flake.wrapperModules.helix-pc ];
  };
in
{
  flake.wrappers = { inherit helix-pc helix-work; };
  flake.modules.nixos.helix =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.helix;
      finalPackage = wrappers."helix-${cfg.variant}".wrap { inherit pkgs; };
    in
    {
      options.programs.helix.variant = lib.mkOption {
        type = lib.types.enum [
          "pc"
          "work"
        ];
      };
      config.environment.systemPackages = [ finalPackage ];
    };
  flake.modules.nixos.pc = {
    imports = [ nixosModules.helix ];
    programs.helix.variant = lib.mkDefault "pc";
  };
  flake.modules.nixos.work = {
    programs.helix.variant = "work";
  };
}
