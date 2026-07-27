# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ lib, ... }:
let
  command_string = lib.readFile ./jst.nu;
  command_package =
    {
      inferno,
      jujutsu-pc,
      writers,
    }:
    writers.writeNuBin "jst" {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [
          inferno
          jujutsu-pc
        ]}"
      ];
    } command_string;
in
{

  perSystem =
    {
      inputs',
      pkgs,
      config,
      ...
    }:
    let
      inherit (pkgs) nufmt;
    in

    {
      packages.runCommand = command_package {
        inherit (pkgs) inferno writers;
        inherit (config.packages) jujutsu-pc;
      };
      devShells.commands = pkgs.mkShell {
        packages = [
          config.packages.runCommand
        ];
      };
      devShells.default = pkgs.mkShell {
        TACK_NIX_CONF_TOKENS = "1";
        inputsFrom = [ config.devShells.commands ];
        packages = [
          # config.packages.kakoune-pc # insanely borked
          nufmt
        ]
        ++ lib.attrValues {
          inherit (config.packages) jujutsu-pc;
          inherit (inputs'.tack.packages) tack;
          inherit (pkgs.lixPackageSets.stable) nix-fast-build;
          inherit (pkgs)
            dix
            github-cli
            hydra-check
            jq
            kdlfmt
            meld
            nixd
            nixfmt
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
    };
}
