# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  ...
}:
let
  inherit (inputs) treefmt-nix;
in
{
  imports = [
    # Optional: use external flake logic, e.g.
    treefmt-nix.flakeModule
  ];

  # NOTE debug is always true for lsp support
  debug = true;

  perSystem =
    {
      pkgs,
      system,
      unstablePkgs,
      ...
    }:
    let
      bizhub-225i = inputs."bizhub-225i";
      pkgsBuilder =
        {
          src,
          overlays ? [ ],
          config ? { },
        }:
        import src {
          inherit system overlays;
          config = {
            allowUnfree = true;
          }
          // config;
        };
    in
    {

      _module.args = {
        pkgs = pkgsBuilder {
          src = inputs.nixpkgs;
        };
        unstablePkgs = pkgsBuilder {
          src = inputs.nix-unstable;
          overlays = [
            inputs.affinity-nix.overlays.default
          ];
        };
      };
      packages = {
        bizhub-225i = pkgs.callPackage ../../pkgs/bizhub-225i.nix { src = bizhub-225i; };
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
        ".tack/*"
      ];
      wrappers.pkgs = unstablePkgs;
    };

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
