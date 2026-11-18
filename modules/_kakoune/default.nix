# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  wlib,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (pkgs)
    stdenv
    kakoune
    kakoune-lsp
    fetchFromGitHub
    parinfer-rust
    nixd
    nixfmt
    wl-clipboard-rs
    ;
  inherit (pkgs.python3Packages) editorconfig;

  buildPlugin =
    rtpPath:
    let
      src = ./build-kakoune-plugin.nix;
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
    version = "0-unstable-2025-07-31";
    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "kakoune";
      rev = "abb4e7c2939361825a69cf02bec9e6b782adf5cc";
      hash = "sha256-myR5LrlucAozHU3uQE+3Q0nMtl19ksG5anMSj4sJzIo=";
    };
  };
  kak-plugin-lsp = pkgs.runCommand "kak-plugin-lsp" { } ''
    mkdir -p $out/share/kak/bin
    ln -s ${kakoune-lsp}/bin/kak-lsp $out/share/kak/bin
  '';
in

{
  options = {
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "List of Kakoune plugins as derivations";
    };
  };
  imports = [
    wlib.modules.default
    ./kakrc.nix
  ];
  config = {
    package = kakoune;
    plugins = [
      catppuccin
      parinfer-rust
      kak-plugin-lsp
    ];

    runtimePkgs =
      lib.map
        (data: {
          inherit data;
          name = data.pname;
        })
        [
          nixd
          nixfmt
          editorconfig
          wl-clipboard-rs
        ];
    overrides = [
      {
        type = "override";
        data = prev: {
          plugins = prev.plugins or [ ] ++ config.plugins;
        };
      }
    ];
  };
}
