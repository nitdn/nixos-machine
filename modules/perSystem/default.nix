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
  inherit (config) meta;
in
{
  imports = [
    # Optional: use external flake logic, e.g.
    inputs.flake-parts.flakeModules.modules
    inputs.treefmt-nix.flakeModule
  ];

  debug = true;

  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    let
      buildInputs = [
        pkgs.makeWrapper
        pkgs.libtiff.out
      ];
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) meta.unfreeNames;
        overlays = [
          inputs.nix-on-droid.overlays.default
        ];
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.devShells.commands ];
        packages = [
          config.packages.jujutsu-pc
          pkgs.bashInteractive
          pkgs.cloc
          pkgs.dix
          pkgs.github-cli
          pkgs.hydra-check
          pkgs.jq
          pkgs.kdlfmt
          pkgs.meld
          pkgs.nh
          pkgs.nil
          pkgs.nixd
          pkgs.nixfmt
          pkgs.pandoc
          pkgs.reuse
          pkgs.sops
          pkgs.taplo
          pkgs.tinymist
          pkgs.tokei
          pkgs.typstyle
          pkgs.vscode-langservers-extracted
          pkgs.yaml-language-server
        ];
      };
      packages = {
        bizhub-225i = pkgs.callPackage ../../pkgs/bizhub-225i.nix {
          inherit (inputs) bizhub-225i;
        };
        epson-l3212 = pkgs.callPackage ../../pkgs/epson-l3212.nix {
          inherit (inputs) epson-202101w;
        };
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
      checks.reuse =
        pkgs.runCommand "reuse"
          {
            src = inputs.self.outPath;
            nativeBuildInputs = [ pkgs.reuse ];
          }
          ''
            cd $src
            reuse lint | tac >&2
            mkdir $out
          '';
      treefmt.programs =
        lib.genAttrs
          [
            "actionlint"
            "deadnix"
            "just"
            "nixfmt"
            "shfmt"
            "sqlfluff-lint"
            "statix"
            "taplo"
            "typstyle"
            "yamlfmt"
            "sqlfluff"
            "typos"
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
      ];
    };

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
