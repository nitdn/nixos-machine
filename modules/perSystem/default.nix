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
  inherit (inputs) flake-parts treefmt-nix wrappers;
in
{
  imports = [
    # Optional: use external flake logic, e.g.
    flake-parts.flakeModules.modules
    treefmt-nix.flakeModule
    wrappers.flakeModules.wrappers
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
      inherit (config.nvfetched) bizhub-225i epson-202101w;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) meta.unfreeNames;
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
          pkgs.nvfetcher
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
          inherit (bizhub-225i) src;
        };
        epson-l3212 = pkgs.callPackage ../../pkgs/epson-l3212.nix {
          inherit (epson-202101w) src;
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
        "_**"
      ];
    };

  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
