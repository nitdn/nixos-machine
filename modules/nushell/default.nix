# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ inputs, moduleWithSystem, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      packages.zoxide-nushell =
        pkgs.runCommand "zoxide-nushell-integration"
          {
            nativeBuildInputs = [ pkgs.zoxide ];
          }
          ''
            zoxide init nushell > $out
            cat << EOF >> $out

            def "nu-complete zoxide path" [context: string] {
                let parts = \$context | split row " " | skip 1
                {
                  options: {
                    sort: false,
                    completion_algorithm: substring,
                    case_sensitive: false,
                  },
                  completions: (^zoxide query --list --exclude \$env.PWD -- ...\$parts | lines),
                }
              }

            def --env --wrapped z [...rest: string@"nu-complete zoxide path"] {
              __zoxide_z ...\$rest
            }
            EOF
          '';
      packages.nuPackage =
        (inputs.wrappers.wrapperModules.nushell.apply {
          inherit pkgs;
          "config.nu".content = ''
            source ${./config.nu}
            source ${config.packages.zoxide-nushell}
          '';
        }).wrapper;
    };
  flake.modules.nixos.pc = moduleWithSystem (
    { config, ... }:
    let
      inherit (config.packages) nuPackage;
    in
    { pkgs, ... }:
    {
      environment.shells = [ nuPackage ];
      environment.systemPackages = [
        nuPackage
        # For completions
        pkgs.carapace
        pkgs.zsh
      ];

      programs.bash.interactiveShellInit = ''
        if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
          exec nu
        fi
      '';
    }
  );
}
