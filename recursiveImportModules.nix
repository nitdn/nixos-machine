# SPDX-FileCopyrightText: 2026 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

lib: modulesPath:
let
  inherit (lib)
    hasPrefix
    ;
  inherit (lib.fileset)
    fileFilter
    intersection
    toList
    ;
  inherit (lib.path)
    removePrefix
    subpath
    ;
  nixModules = fileFilter (file: file.hasExt "nix") modulesPath;
  filterIgnored =
    pathRef:
    pathRef
    |> removePrefix modulesPath
    |> subpath.components
    |> lib.all (item: !hasPrefix "_" item);
in
modulesPath
|> intersection nixModules
|> toList
|> lib.filter filterIgnored
