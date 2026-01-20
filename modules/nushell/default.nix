# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  inputs,
  moduleWithSystem,
  flake-parts-lib,
  lib,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (_: {
    options.wrappers.nushell = lib.mkOption {
      description = "Nushell wrapper options";
      type = lib.types.lazyAttrsOf (
        lib.types.submodule {
          options.extraConfig = lib.mkOption {
            description = "Nushell config";
            type = lib.types.lines;
            default = "";
          };
        }
      );
    };
  });
  config.perSystem =
    { pkgs, config, ... }:
    {
      packages.zoxide-nushell =
        pkgs.runCommand "zoxide-nushell-integration"
          {
            nativeBuildInputs = [ pkgs.zoxide ];
          }
          ''
            zoxide init nushell > $out
            echo ${lib.strings.escapeShellArg ''
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
            ''} >> $out
          '';
      packages.nuWrapped =
        (inputs.wrappers.wrapperModules.nushell.apply {
          inherit pkgs;
          "config.nu".content = ''
            ${config.wrappers.nushell.pc.extraConfig}
            source ${./config.nu}
            source ${config.packages.zoxide-nushell}
          '';
        }).wrapper;
      wrappers.kitty.pc.settings.shell = "nu";
    };
  config.flake.modules.nixos.pc = moduleWithSystem (
    { config, ... }:
    let
      inherit (config.packages) nuWrapped;
    in
    { pkgs, ... }:
    {
      environment.shells = [ nuWrapped ];
      environment.systemPackages = [
        nuWrapped
        # For completions
        pkgs.carapace
        pkgs.fish
        pkgs.zsh

      ];
    }
  );

}
