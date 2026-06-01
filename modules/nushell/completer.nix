# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  flake.wrappers.nushell-pc =
    { pkgs, lib, ... }:
    {
      "config.nu".content = /* nu */ ''
        let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans | from json
        }

        $env.config = {

          # ...
          completions: {
            external: {enable: true, completer: $carapace_completer}
          }
          # ...
        }'';
      runtimePkgs = lib.attrValues {
        carapace = pkgs.carapace.overrideAttrs (
          finalAttrs: _: {
            version = "1.7.0";
            src = pkgs.fetchFromGitHub {
              owner = "carapace-sh";
              repo = "carapace-bin";
              tag = "v${finalAttrs.version}";
              hash = "sha256-gEIz6E6p3Z01O3T1uiEQH6hL1XJuEAWocTk21uTqkzM=";
            };

            vendorHash = "sha256-wggsRvNbqt6DtdYyQ+JQ6k7PGaj9uL7FK+lCF0e6LDw=";
          }
        );
      };
    };
  flake.modules.nixos.pc = {
    programs.fish.enable = true;
    documentation.man.cache.generateAtRuntime = true;
  };
}
