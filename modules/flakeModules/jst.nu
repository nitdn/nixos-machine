# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# These are the hosts I have
def hostnames [] { ["tjmaxxer" "msi-colgate" "disko-elysium"] }

# Push to the CI mirror
@category  'Remote operations'
def "main ci" [revset: string = @- # The jj revset
] {
  jj git push -c ($revset) --remote flake-mirror

  jj git push -c ($revset) --remote tngl-mirror
}

@category  'Remote operations'
def "main change-id" [revset: string = @- # The jj revset
] {
  jj log -r ($revset) -T "change_id.short()" --no-graph
}

# Create a Pull Request
@category  'Remote operations'
def "main pr" [revset: string = @- # The jj revset
] {
  main ci

  gh pr create --head push-(main change-id $revset) --fill-first
}

# Merge into trunk and commit to remotes
@category  'Remote operations'
def "main trunk" [revset: string = @- # The jj revset
] {
  jj bookmark set main --to ($revset)

  jj git push -r ($revset) --remote flake-mirror --bookmark main

  jj git push -r ($revset) --remote tngl-mirror --bookmark main

  jj git push -r ($revset) --remote origin
}

# Create a snapshotted watcher
@category  'Remote operations'
def "main new" [] {

  # Watch is uncapturable for some reason
  watch $"($nu.home-dir)/nixos-machine" --glob=**/*.nix {|| nix flake check; jj new }
}

# Large squashes that flatten multiple revisions
@category  'Remote operations'
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

# Attaches SPDX Identifiers to new files
def "main reuse" --wrapped [...args: path] {
  (
reuse annotate
--copyright="Nitesh Kumar Debnath <nitkdnath@gmail.com>"
--license="GPL-3.0-or-later" ...$args
)
}

@deprecated  "I don't really care about nfb anymore"
def "main fast" [machine: string@hostnames] {
  nix-fast-build --flake=$".#nixosConfigurations.($machine).config.system.build.toplevel"

  nh os switch .
}

# Remote deploys
def "main deploy" [hostname: string@hostnames # The hostname argument
 --switch(-s) # Whether to use switch or test
] {
  let command = if $switch { "switch" } else { "test" }

  (
nh os $command .
--hostname $hostname --target-host $"(whoami)@($hostname).local"
)
}

def "main switch" [hostname: string@hostnames] {
  nixos-rebuild switch --flake . --elevate run0
}

# Generates a tack lock update
def "main lock" [] {
  $env.TACK_NIX_CONF_TOKENS = 1

  let changelog = tack look --verbose | lines | where { $in !~ "unchanged|fixed" }

  if $changelog == [] {
    print "Nothing changed"

    return
  }

  jj new -B @

  jj desc -m "tack: update" -m $"($changelog | str join "\n")"

  $changelog | where {$in =~ "^\\w"} | parse "{input}: {changes}" | get input | tack update ...$in

  jj next --edit
}

# Get an evaluation perf time report
def --wrapped "main eval" [hostname: string@hostnames = tjmaxxer # Host config to evaluate
 ...rest # Extra arguments
] {
  (
NIX_SHOW_STATS=1 nix eval $".#nixosConfigurations.($hostname).config.system.build.toplevel"
--substituters " " --no-eval-cache --read-only ...$rest
)
}

# Get a profiler flamegraph
def "main eval profiler" [hostname: string@hostnames = tjmaxxer # Host config to profile
] {
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

def main [] { help main }
