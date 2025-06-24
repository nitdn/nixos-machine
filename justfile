ewd action:
    eww --config ./eww {{action}} example

sysupgrade:
    nix flake update
    nh os switch .
    nh home switch .

gc:
    nh clean all --keep-since 7d
    nh clean user --keep-since 7d
