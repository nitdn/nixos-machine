[working-directory: '../eww']
test-dir:
    pwd

ewd action:
    eww --config ./eww {{action}} example

[working-directory: '../next']
lock:
    git fetch
    git merge origin/update_flake_lock_action
    
[working-directory: '../main']
freeze:
    git merge next
    git push

[working-directory: '../main']
sysupgrade:
    nh os switch .
    nh home switch .

gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
