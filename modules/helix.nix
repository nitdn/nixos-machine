# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  config,
  lib,
  moduleWithSystem,
  ...
}:
let
  nixosModules = config.flake.modules.nixos;
in
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      wrappers.helix.pc = {
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
      wrappers.helix.work = wrappers.helix.pc // {
        settings = {
          theme = "catppuccin_latte";
        };
      };
    in
    {
      inherit wrappers;
    };
  flake.modules.nixos.helix =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.helix;
    in
    {
      options.programs.helix.package = lib.mkPackageOption pkgs "helix" { };
      config.environment.systemPackages = [ cfg.package ];
    };
  flake.modules.nixos.pc = moduleWithSystem (
    { config, ... }:
    {
      imports = [ nixosModules.helix ];
      programs.helix.package = lib.mkDefault config.packages.helix-pc;
    }
  );
  flake.modules.nixos.work = moduleWithSystem (
    { config, ... }:
    {
      programs.helix.package = config.packages.helix-work;
    }

  );
}
