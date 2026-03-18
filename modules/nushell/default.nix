# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  config,
  lib,
  ...
}:
let
  inherit (config.flake) wrappers;
  zoxide_completer = /* nu */ ''
    def "nu-complete zoxide path" [context: string] {
        let parts = $context | split row " " | skip 1
        {
          options: {
            sort: false,
            completion_algorithm: substring,
            case_sensitive: false,
          },
          completions: (^zoxide query --list --exclude $env.PWD -- ...$parts | lines),
        }
      }

    def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
      __zoxide_z ...$rest
    }
  '';
in
{
  flake = {
    wrappers.nushell-pc =
      { wlib, pkgs, ... }:
      let
        zoxide-nushell =
          pkgs.runCommand "zoxide-nushell-integration"
            {
              nativeBuildInputs = [ pkgs.zoxide ];
            }
            ''
              zoxide init nushell > $out
              echo ${lib.strings.escapeShellArg zoxide_completer} >> $out
            '';
        carapace-nushell =
          pkgs.runCommand "carapace-nushell-integration"
            {
              nativeBuildInputs = [ pkgs.carapace ];
            }
            ''
              carapace _carapace nushell > $out
            '';
      in
      {
        imports = [ wlib.wrapperModules.nushell ];
        "config.nu".content = ''
          source ${zoxide-nushell}
          source ${carapace-nushell}
        '';
      };
    wrappers.kitty-pc.settings.shell = "nu";
    modules.nixos.pc =
      { pkgs, ... }:
      let
        nushell-pc = wrappers.nushell-pc.wrap { inherit pkgs; };
      in
      {
        environment.shells = [ nushell-pc ];
        environment.systemPackages = [
          nushell-pc
          # For completions
          pkgs.carapace
          pkgs.fish
          pkgs.zsh
        ];
      };
  };
}
