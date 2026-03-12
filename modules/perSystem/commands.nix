# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

let
  command_string = /* nu */ ''
    def "main ci" [] {
        jj squash
        jj git push -c @- --remote flake-mirror
    }

    def "main change-id" [ revset=@- ] {
        jj log -r ($revset) -T "change_id.short()" --no-graph
    }

    def "main pr" [ revset=@- ] {
        gh pr create --head push-(main change-id $revset) --fill
    }

    def "main trunk" [ revset=@- ] {
        jj bookmark set -r ($revset) main
        jj git push -r ($revset) --remote flake-mirror --bookmark main
        jj git push -r ($revset) --remote origin
    }

    def "main new" [] {
        jj commit
        jj git push -c @- --remote flake-mirror
        main pr
    }

    def "main pwget" [ field: string, path: path=secrets/core.yaml ] {
        sops decrypt --extract $"['($field)']['password']" ($path)
    }

    def "main throttle" --wrapped [
        ...cmd: string ] {(
        systemd-inhibit --what=sleep:shutdown
        systemd-run --user --scope
        --property=MemoryMax=8G --property=CPUWeight=500
        ...$cmd
        )}

    def "main reuse" --wrapped [...args: string ] {(
        reuse annotate
        --copyright="Nitesh Kumar Debnath <nitkdnath@gmail.com>"
        --license="GPL-3.0-or-later" ...$args
    )} 

    def "main upgrade" [ machine: string ] {
        nix run github:Mic92/nix-fast-build -- --flake=.#nixosConfigurations.($machine).config.system.build.toplevel
        nh os switch .
    }

    def main [] { help main }
  '';
in
{
  perSystem =
    { pkgs, ... }:
    let
      command_package = pkgs.writers.writeNuBin "run" command_string;
    in
    {
      devShells.commands = pkgs.mkShell {
        packages = [
          command_package
        ];
      };
    };
}
