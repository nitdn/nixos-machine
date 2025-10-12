[working-directory('../next')]
test-vps:
    nh os test --hostname vps01 --build-host root@vps01 --target-host root@vps01 .

@pwget item:
    sops decrypt --extract '["{{ item }}"]["password"]' secrets/core.yaml

@pwgen len:
    pwgen -s {{ len }} 1

ewd action:
    eww --config ./eww {{ action }} example

[working-directory('../next')]
lock:
    git fetch flake-mirror
    # I hate this it fucks up my history 
    git merge flake-mirror/update_flake_lock_action
    git push flake-mirror

[working-directory('../main')]
freeze:
    git fetch origin
    git merge origin/next
    git push

[working-directory('../main')]
sysupgrade: freeze gc
    nh os switch .

[working-directory('../main')]
home:
    nh home switch .

gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
