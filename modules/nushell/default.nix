# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  inputs,
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
        options: {sort: false, completion_algorithm: substring, case_sensitive: false}
        completions: (^zoxide query --list --exclude $env.PWD -- ...$parts | lines)
      }
    }

    def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
      __zoxide_z ...$rest
    }'';
in
{
  flake = {
    wrappers.nushell-pc =
      { wlib, pkgs, ... }:
      let
        inherit (pkgs.stdenv.hostPlatform) system;
        zoxide-nushell =
          pkgs.runCommand "zoxide.nu"
            {
              nativeBuildInputs = [ pkgs.zoxide ];
            }
            ''
              zoxide init nushell --no-cmd > $out
              echo ${lib.strings.escapeShellArg zoxide_completer} >> $out
            '';
        cade-nushell =
          pkgs.runCommand "cade.nu"
            {
              nativeBuildInputs = [ inputs.cade.packages.${system}.default ];
            }
            ''
              cade  hook nushell >> "$out"
            '';
      in
      {
        imports = [ wlib.wrapperModules.nushell ];
        "config.nu".content = ''
          source ${zoxide-nushell}
          source ${cade-nushell}
        '';
      };
    wrappers.kitty-pc.settings.shell = "nu";
    modules.nixos.pc =
      { pkgs, ... }:
      let
        nushell-pc = wrappers.nushell-pc.wrap { inherit pkgs; };
      in
      {
        imports = [ inputs.cade.nixosModules.default ];
        programs.cade.enable = true;
        environment.shells = [
          nushell-pc
          pkgs.stdenv.builder
        ];
        environment.systemPackages = [
          nushell-pc
        ];
      };
  };
}
