# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
_: {
  flake.wrappers.jujutsu-pc =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.jujutsu ];
      settings = {
        user.name = "Nitesh Kumar Debnath";
        user.email = "nitkdnath@gmail.com";
        signing = {
          behavior = "own";
          backend = "ssh";
          key = "~/.ssh/id_ed25519.pub";
        };
        revsets = {
          bookmark-advance-from = "heads(::to & bookmarks())";
          bookmark-advance-to = "closest_pushable(@)";
        };
        revset-aliases."closest_pushable(to)" =
          ''heads(::to & mutable() & ~description(exact:"") & (~empty() | merges()))'';
        template-aliases.default_commit_description = ''
          "scope: message
          JJ: body

          JJ: Closes #NNNN
          "'';
      };
    };

  flake.modules.nixos.pc = _: {
    wrappers.jujutsu-pc.enable = true;
  };
}
