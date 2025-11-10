# Builds character
[group('pinning')]
test hostname='vps01':
    nixos-rebuild test --flake . \
    --build-host root@{{ hostname }} \
    --target-host root@{{ hostname }} 

[group('pinning')]
build hostname='vps01':
    nixos-rebuild build --flake . \
    --build-host root@{{ hostname }} \
    --target-host root@{{ hostname }} 

# Get password from sops
[group('password')]
@pwget item:
    sops decrypt --extract '["{{ item }}"]["password"]' secrets/core.yaml

# Generate a password of desired length
[group('password')]
@pwgen len='17':
    pwgen -s {{ len }} 1

# Ideally updates the lockfiles. WARNING: Run this command exclusively on unstaged working trees
[group('pinning')]
lock:
    jj git fetch --remote flake-mirror
    jj rebase -d update_flake_lock_action@flake-mirror

# Conventional commits, cannot really cancel though
desc revset='@':
    jj describe -m"type(scope): description" \
            -m"body" \
            -m"footer" --edit {{ revset }}

# Updates both mirrors.
[group('pinning')]
push:
    jj bookmark set main
    nix fmt && nix flake check
    jj git push -r @ --remote flake-mirror --bookmark main
    jj git push -r @ --remote origin

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
