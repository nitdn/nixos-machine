# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ lib, ... }:
let
  command_string = /* nu */ ''
    def hostnames [] { ["tjmaxxer" "msi-colgate" "disko-elysium"] }

    def "main ci" [] {
      jj squash
      jj git push -c @- --remote flake-mirror
    }

    def "main change-id" [revset = @-] {
      jj log -r ($revset) -T "change_id.short()" --no-graph
    }

    def "main pr" [revset = @-] {
      gh pr create --head push-(main change-id $revset) --fill
    }

    def "main trunk" [revset = @-] {
      jj bookmark set -r ($revset) main
      jj git push -r ($revset) --remote flake-mirror --bookmark main
      jj git push -r ($revset) --remote origin
    }

    def "main new" [] {
      jj commit
      jj git push -c @- --remote flake-mirror
      main pr
    }

    def "main nufmt" [] {
      topiary-nushell fmt -l nu
    }

    def "main pwget" [field: string path: path = secrets/core.yaml] {
      sops decrypt --extract $"['($field)']['password']" ($path)
    }

    def "main throttle" --wrapped [
      ...cmd: string
    ] {
      (
        systemd-inhibit --what=sleep:shutdown
        systemd-run --user --scope
        --property=MemoryMax=8G --property=CPUWeight=500
        ...$cmd
      )
    }

    def "main reuse" --wrapped [...args: path] {
      (
        reuse annotate
        --copyright="Nitesh Kumar Debnath <nitkdnath@gmail.com>"
        --license="GPL-3.0-or-later" ...$args
      )
    }

    def "main fast" [machine: string@hostnames] {
      nix-fast-build --flake=$".#nixosConfigurations.($machine).config.system.build.toplevel"
      nh os switch .
    }

    def "main deploy" [--switch (-s) hostname: string@hostnames] {
      let command = if $switch { "switch" } else { "test" }
      (
        nh os $command .
        --hostname $hostname --target-host $"ssmvabaa@($hostname).local"
      )
    }

    def "main lock" [] {
      nix flake update --commit-lock-file
      nvfetcher --commit-changes
    }

    def "main eval" [hostname: string@hostnames = tjmaxxer] {
      (
        NIX_SHOW_STATS=1 nix eval $".#nixosConfigurations.($hostname).config.system.build.toplevel"
        --substituters " " --no-eval-cache --read-only
      )
    }

    def "main eval profiler" [hostname: string@hostnames = tjmaxxer] {
      (
        nix eval $".#nixosConfigurations.($hostname).config.system.build.toplevel"
        --substituters " " --no-eval-cache --read-only
        --impure --eval-profiler flamegraph --eval-profiler-frequency 9999
      )
      (
        inferno-flamegraph
        --width 10000 nix.profile o> $"result-($hostname).svg"
      )
      zen result-($hostname).svg
    }
    def main [] { help main }'';
  command_package =
    pkgs: config:
    pkgs.writers.writeNuBin "run" {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [
          pkgs.inferno
          pkgs.nvfetcher
          pkgs.nix-fast-build
          config.packages.jujutsu-pc
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
    {
      packages.runCommand = command_package pkgs config;
      devShells.commands = pkgs.mkShell {
        packages = [
          config.packages.runCommand
        ];
      };
      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.devShells.commands ];
        packages = lib.attrValues {
          inherit (config.packages) jujutsu-pc;
          inherit (inputs'.topiary-nushell.packages) default;
          inherit (pkgs)
            bashInteractive
            dix
            github-cli
            hydra-check
            jq
            kdlfmt
            meld
            nh
            nil
            nixd
            nixfmt
            nvfetcher
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
