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
  inherit (inputs) treefmt-nix;
  inherit (config.flake) sources;
in
{
  imports = [
    # Optional: use external flake logic, e.g.
    treefmt-nix.flakeModule
  ];

  debug = true;

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      buildInputs = [
        pkgs.makeWrapper
        pkgs.libtiff.out
      ];

      inherit (pkgs.callPackage sources.raw { }) bizhub-225i epson-202101w;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      packages = {
        bizhub-225i = pkgs.callPackage ../../pkgs/bizhub-225i.nix bizhub-225i;
        epson-l3212 = pkgs.callPackage ../../pkgs/epson-l3212.nix epson-202101w;
        naps2-wrapped = pkgs.naps2.overrideAttrs (
          _finalAttrs: previousAttrs: {
            buildInputs = previousAttrs.buildInputs or [ ] ++ buildInputs;
            postFixup = previousAttrs.postFixup or "" + ''
              chmod +x $out/lib/naps2/_linux/tesseract 
              wrapProgram $out/bin/naps2 --prefix LD_LIBRARY_PATH : \
              ${toString (lib.makeLibraryPath buildInputs)}
            '';
          }
        );
      };
      treefmt.programs =
        lib.genAttrs
          [
            "actionlint"
            "deadnix"
            "flake-edit"
            "nixfmt"
            "shfmt"
            "sqlfluff-lint"
            "statix"
            "taplo"
            "typstyle"
            "yamlfmt"
            "sqlfluff"
            "typos"
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
