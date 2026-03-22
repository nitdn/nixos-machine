# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  lib,
  inputs,
  ...
}:
let
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
      inherit (config.nvfetcher) bizhub-225i epson-202101w;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      nvfetcher = pkgs.callPackage ../../_sources/generated.nix { };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.devShells.commands ];
        packages = lib.attrValues {
          inherit (config.packages) jujutsu-pc;
          inherit (pkgs)
            bashInteractive
            cloc
            dix
            github-cli
            hydra-check
            jq
            kdlfmt
            meld
            nh
            nil
            nixd
            nixfmt
            nix-fast-build
            nvfetcher
            onefetch
            pandoc
            reuse
            sops
            taplo
            tinymist
            tokei
            typstyle
            vscode-langservers-extracted
            yaml-language-server
            zizmor
            ;
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
