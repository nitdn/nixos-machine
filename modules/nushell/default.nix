# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  inputs,
  lib,
  config,
  ...
}:
let
  zoxide_completer = /* nu */ ''
    def "nu-complete zoxide path" [place: record] {
      let parts = $place.command | skip 1

      {
        options: {sort: false, completion_algorithm: substring, case_sensitive: false}
        completions: (^zoxide query --list --exclude $env.PWD -- ...$parts | lines)
      }
    }

    def --env --wrapped z [...rest: string@"nu-complete zoxide path"] { __zoxide_z ...$rest }'';
in
{
  flake = {
    wrappers.nushell-pc =
      { wlib, pkgs, ... }:
      let
        zoxide-nushell =
          pkgs.runCommand "zoxide.nu"
            {
              nativeBuildInputs = [ pkgs.zoxide ];
            }
            ''
              zoxide init nushell --no-cmd > $out
              echo ${lib.strings.escapeShellArg zoxide_completer} >> $out
            '';
      in
      {
        imports = [ wlib.wrapperModules.nushell ];
        "config.nu".content = ''
          source ${zoxide-nushell}
          alias y = yazi
        '';
      };
    modules.nixos.pc =
      {
        pkgs,
        config,
        unstablePkgs,
        ...
      }:
      let
        cadePackage = inputs.cade.packages.${config.nixpkgs.hostPlatform.system}.default;
      in
      {
        wrappers.nushell-pc = {
          enable = true;
          pkgs = lib.mkForce unstablePkgs;
          "config.nu".content = config.programs.cade.shellSnippets.nushell;
        };
        imports = [ inputs.cade.nixosModules.default ];
        programs.cade = {
          enable = true;
          package = cadePackage;
        };
        environment.shells = [
          pkgs.stdenv.builder
          config.wrappers.nushell-pc.wrapper
        ];
      };
  };
}
