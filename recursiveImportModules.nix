# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

lib: modulesPath:
let
  inherit (lib)
    cleanSourceWith
    hasPrefix
    pipe
    ;
  inherit (lib.fileset)
    fileFilter
    fromSource
    intersection
    toList
    ;
in
pipe modulesPath [
  (
    # TODO: Update it to fileset based filtering when it starts
    # allowing nested basename checks
    src:
    cleanSourceWith {
      filter = path: _: !hasPrefix "_" (baseNameOf path);
      inherit src;
    }
  )
  fromSource
  (intersection (fileFilter (file: file.hasExt "nix") modulesPath))
  toList
]
