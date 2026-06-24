# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
{ lib, ... }:
let
  command_string = /* nu */ ''
    def hostnames [] { ["tjmaxxer" "msi-colgate" "disko-elysium"] }

    def "main ci" [revset: string = @-] {
      jj git push -c ($revset) --remote flake-mirror
      jj git push -c ($revset) --remote tngl-mirror
    }

    def "main change-id" [revset: string = @-] {
      jj log -r ($revset) -T "change_id.short()" --no-graph
    }

    def "main pr" [revset: string = @-] {
      main ci
      gh pr create --head push-(main change-id $revset) --fill
    }

    def "main trunk" [revset: string = @-] {
      jj bookmark set main --to ($revset)

      jj git push -r ($revset) --remote flake-mirror --bookmark main
      jj git push -r ($revset) --remote tngl-mirror --bookmark main

      jj git push -r ($revset) --remote origin
    }

    def "main new" [] {

      # Watch is uncapturable for some reason
      watch $"($nu.home-dir)/nixos-machine" --glob=**/*.nix {|| nix flake check; jj new }

      direnv reload
    }

    def "main squash" [base: string] {
      jj squash -t $base -f $"($base)::@-"
    }

    def "main pwget" [field: string, path: path = secrets/core.yaml] {
      sops decrypt --extract $"['($field)']['password']" ($path)
    }

    def "main throttle" --wrapped [...cmd: string] {
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

    def "main deploy" [hostname: string@hostnames, --switch(-s)] {
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
          ) e>| lines | skip until { $in == "{" } | str join | from json | to nuon | print -e $in
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
          inherit (config.packages) jujutsu-pc kakoune-pc;
          inherit (inputs'.nufmt.packages) default;
          inherit (pkgs)
            bashInteractive
            dix
            flake-edit
            github-cli
            hydra-check
            jq
            kdlfmt
            meld
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
