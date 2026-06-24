# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Baseline for a kakoune wrapper
{ inputs, ... }:
{
  flake.wrappers.kakoune-pc =
    {
      pkgs,
      lib,
      wlib,
      ...
    }:
    let
      inherit (pkgs)
        stdenv
        kakoune
        fetchFromGitHub
        parinfer-rust
        ;

      buildPlugin =
        rtpPath:
        let
          src = "${inputs.nixpkgs}/pkgs/applications/editors/kakoune/plugins/build-kakoune-plugin.nix";
        in
        (import src {
          inherit
            lib
            stdenv
            rtpPath
            ;
        }).buildKakounePluginFrom2Nix;

      catppuccin = buildPlugin "share/kak/colors" {
        pname = "kakoune-catppuccin";
        version = "0-unstable-2024-03-29";
        src = fetchFromGitHub {
          owner = "catppuccin";
          repo = "kakoune";
          rev = "7f187d9da2867a7fda568b2135d29b9c00cfbb94";
          hash = "sha256-acBOQuJ8MgsMKdvFV5B2CxuxvXIYsg11n1mHEGqd120=";
        };
      };
      kakoune-lsp = pkgs.kakoune-lsp.overrideAttrs (
        finalAttrs: _:
        let
          inherit (pkgs) fetchFromGitHub;
        in
        {
          version = "21.0.0";

          src = fetchFromGitHub {
            owner = "kakoune-lsp";
            repo = "kakoune-lsp";
            rev = "v${finalAttrs.version}";
            hash = "sha256-W5tZyVc5iLeiNf2oYt5fNEMnge/xo4F5q7fU5lF3qIw=";
          };
          cargoHash = "sha256-96X5xwZkPTX4jUfmoZODGKJsUuBcDCZtjH+I3Jn3F/I=";
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) pname src version;
            hash = finalAttrs.cargoHash;
          };
        }
      );
      kak-plugin-lsp = pkgs.runCommand "kak-plugin-lsp" { } ''
        mkdir -p $out/share/kak/bin
        ln -s ${kakoune-lsp}/bin/kak-lsp $out/share/kak/bin
      '';
    in
    {
      imports = [ wlib.modules.default ];
      package = kakoune;
      overrides = [
        {
          type = "override";
          data = prev: {
            plugins = prev.plugins or [ ] ++ [
              catppuccin
              parinfer-rust
              kak-plugin-lsp
            ];
          };
        }
      ];
    };
}
