# Builds character
[group('pinning')]
test hostname:
    nixos-rebuild test --flake . \
    --build-host root@{{ hostname }} \
    --target-host root@{{ hostname }} 

[group('pinning')]
build hostname:
    nixos-rebuild build --flake . \
    --build-host root@{{ hostname }} \
    --target-host root@{{ hostname }} 

# Get password from sops
[group('password')]
@pwget item:
    sops decrypt --extract '["{{ item }}"]["password"]' secrets/core.yaml

# Generate a password of desired length
[group('password')]
@pwgen len:
    pwgen -s {{ len }} 1

# Ideally updates the lockfiles. WARNING: Run this command exclusively on unstaged working trees
[group('pinning')]
lock:
    jj git fetch flake-mirror
    jj rebase update_flake_lock_action@flake-mirror

# Updates both mirrors.
[group('pinning')]
push:
    jj bookmark set main
    nix fmt && nix flake check
    jj git push --remote flake-mirror
    jj git push --remote origin

# This one is for whole machines
[group('system')]
sysupgrade:
    nh os switch .

# This one is for houses
[group('system')]
home:
    nh home switch .

# This one is for garbage
[group('system')]
gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
