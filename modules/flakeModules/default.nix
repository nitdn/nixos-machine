# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (inputs) treefmt-nix flake-parts;
in
{
  imports = [
    # Optional: use external flake logic, e.g.
    treefmt-nix.flakeModule
    flake-parts.flakeModules.touchup
  ];

  # NOTE debug is always true for lsp support
  debug = true;

  # Do not use this if debug is true
  touchup.attr = lib.mkIf (!config.debug) (
    lib.genAttrs [ "allSystems" "debug" "modules" "sources" "wrapperModules" "wrappers" ] (_: {
      enable = false;
    })
  );

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let

      inherit (pkgs.callPackage sources.raw { }) bizhub-225i epson-202101w;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.affinity-nix.overlays.default ];
        config = {
          allowUnfree = true;
        };
      };
      packages = {
        bizhub-225i = pkgs.callPackage ../../pkgs/bizhub-225i.nix bizhub-225i;
        epson-l3212 = pkgs.callPackage ../../pkgs/epson-l3212.nix epson-202101w;
      };
      treefmt.programs =
        lib.genAttrs
          [
            "actionlint"
            "deadnix"
            "flake-edit"
            "nixfmt"
            "prettier"
            "shfmt"
            "sqlfluff"
            "sqlfluff-lint"
            "statix"
            "taplo"
            "typos"
            "typstyle"
            "zizmor"
          ]
          (_: {
            enable = true;
          })
        // {
          sqlfluff.dialect = "postgres";
        };
      treefmt.settings.excludes = [
        "**/*.layout.json"
        "secrets/*"
        ".sops.yaml"
        "**/facter.json"
        "_**"
      ];
    };

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
