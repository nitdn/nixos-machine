ewd action:
    eww --config ./eww {{action}} example

lock:
    git switch main
    nix flake update
    git add ./flake.lock
    git commit -m "Bump {{datetime("%F")}}"
    git push
    git switch -
    
sysupgrade:
    nh os switch .
    nh home switch .

gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
