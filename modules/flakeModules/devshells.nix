# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ lib, ... }:
{
  perSystem =
    {
      inputs',
      pkgs,
      config,
      unstablePkgs,
      ...
    }:
    let
      inherit (unstablePkgs) nufmt;
      nuBootStrap =
        let
          runner_cmd = "jst";
        in
        pkgs.writers.writeNuBin runner_cmd ''
          def main --wrapped [ ...args] {
            nu -e $"
              $env.config.show_banner = false
              overlay use --reload scripts
              ${runner_cmd} ($args | str join \s)
            "
          }
        '';
    in

    {
      devShells.default = pkgs.mkShell {
        TACK_NIX_CONF_TOKENS = "1";
        packages = [
          # config.packages.kakoune-pc # insanely borked
          nufmt
          nuBootStrap
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
            onefetch
            pandoc
            reuse
            sops
            tinymist
            tokei
            vscode-langservers-extracted
            yaml-language-server
            ;
        }
        ++ lib.attrValues config.treefmt.build.programs;
      };
    };
}
