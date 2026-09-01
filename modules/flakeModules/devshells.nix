# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ lib, ... }:
let
  command_string = lib.readFile ./jst.nu;
in
{
  flake.wrappers.nushell-pc = { pkgs, config, ... }: {
    runtimePkgs = [ pkgs.inferno ];
    constructFiles = {
      jst-nu = {
        content = command_string;
        relPath = "devlib/jst.nu";
      };
    };
    "config.nu".content = ''
      overlay use --prefix ${config.constructFiles.jst-nu.path}
    '';
  };
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
      devShells.default = pkgs.mkShell {
        TACK_NIX_CONF_TOKENS = "1";
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
