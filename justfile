[working-directory('../next')]
test-vps:
    nixos-rebuild --flake . --target-host root@vps01 test

@pwget item:
    sops decrypt --extract '["{{ item }}"]["password"]' secrets/core.yaml

@pwgen len:
    pwgen -s {{ len }} 1

ewd action:
    eww --config ./eww {{ action }} example

[working-directory('../next')]
lock:
    git fetch origin
    git merge origin/update_flake_lock_action

[working-directory('../main')]
freeze:
    git fetch origin
    git merge origin/next
    git push

[working-directory('../main')]
sysupgrade: freeze
    nh os switch .
    nh home switch .

gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
