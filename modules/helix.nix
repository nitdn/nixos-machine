# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  config,
  lib,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;
  inherit (config.flake) wrappers;
  helix-pc =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.helix ];
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
        }
      ];
      extraPackages = [
        pkgs.nixd
        pkgs.nil
      ];
    };
  helix-work = {
    imports = [ config.flake.wrapperModules.helix-pc ];
    settings.theme = lib.mkDefault "catppuccin_latte";
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
