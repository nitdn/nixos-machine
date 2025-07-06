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
    git fetch
    git merge origin/update_flake_lock_action

[working-directory('../next')]
rebase-to-main:
    git rebase origin/main

[working-directory('../main')]
freeze:
    git fetch
    git merge origin/next --squash
    git commit
    git push
    rebase-to-main

[working-directory('../main')]
sysupgrade: freeze
    nh os switch .
    nh home switch .

gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
