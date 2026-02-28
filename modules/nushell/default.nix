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
let
  inherit (inputs) wrappers;
  staticModules = [
    "${wrappers}/modules/nushell/module.nix"
    "${wrappers}/lib/modules/wrapper.nix"
    "${wrappers}/lib/modules/meta.nix"
    (
      { config, ... }:
      {
        options.extraConfig = lib.mkOption {
          description = "Nushell config";
          type = lib.types.lines;
          default = "";
        };
        config."config.nu".content = ''
          ${config.extraConfig}
          source ${./config.nu}
        '';
      }
    )
  ];
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    let
      inherit (lib.types) attrsOf deferredModuleWith;
    in
    {
      options.wrappers.nushell = lib.mkOption {
        description = "Nushell wrapper options";
        type = attrsOf (deferredModuleWith {
          inherit staticModules;
        });
      };
    }
  );
  config.perSystem =
    { pkgs, config, ... }:
    let
      inherit (config) packages;
    in
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
      wrappers.kitty.pc.settings.shell = "nu";
      wrappers.nushell.pc.extraConfig = ''
        source ${packages.zoxide-nushell}
      '';
    };
  config.flake.modules.nixos.pc = moduleWithSystem (
    { config, ... }:
    let
      inherit (config.packages) nushell-pc;
    in
    { pkgs, ... }:
    {
      environment.shells = [ nushell-pc ];
      environment.systemPackages = [
        nushell-pc
        # For completions
        pkgs.carapace
        pkgs.fish
        pkgs.zsh
      ];
    }
  );

}
