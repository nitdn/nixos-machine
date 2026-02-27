# SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.meta) username;
in
{
  flake.modules.nixos.pc =
    {
      pkgs,
      ...
    }:
    {
      # Edit this configuration file to define what should be installed on
      # your system.  Help is available in the configuration.nix(5) man page
      # and in the NixOS manual (accessible by running ‘nixos-help’).

      # cleanup configs
      nix.optimise.automatic = true;

      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      nix.settings = {
        trusted-users = [
          username
          "@wheel"
        ];
        experimental-features = [
          "nix-command"
          "flakes"
          "auto-allocate-uids"
        ];
        auto-allocate-uids = true;
      };
      nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
      };

      # Bootloader.
      boot.loader.limine.enable = true;
      boot.loader.limine.efiInstallAsRemovable = true;
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
      boot.initrd.systemd.enable = true;
      boot.kernelParams = [
        "zswap.enabled=1" # enables zswap
        "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
        "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
      ];
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      boot.supportedFilesystems = {
        exfat = true;
      };
      services.fwupd.enable = true;
      services.btrfs.autoScrub.enable = lib.mkDefault true;
      hardware.facter.detected.dhcp.enable = false;
      networking = {
        nameservers = [
          # "1.1.1.1" # oh no
          "127.0.0.1"
          "::1"
        ];
        networkmanager.dns = "none";
      };
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      # networking.networkmanager.enable = true;
      services.displayManager.gdm.enable = lib.mkDefault true;
      services.displayManager.gdm.autoSuspend = false;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      services.power-profiles-daemon.enable = true;

      # services.desktopManager.cosmic.enable = true;

      # Set your time zone.
      time.timeZone = "Asia/Kolkata";

      # Select internationalisation properties.
      i18n.extraLocaleSettings = {
        LANGUAGE = "en_IN:en:C:bn_IN:hi_IN";
      };

      i18n.extraLocales = [
        "en_IN/UTF-8"
        "en_US.UTF-8/UTF-8"
        "bn_IN/UTF-8"
        "hi_IN/UTF-8"
      ];

      services.dbus.implementation = "broker";

      fonts.packages = [
        pkgs.noto-fonts
        pkgs.noto-fonts-color-emoji
        pkgs.atkinson-hyperlegible-next
        pkgs.nerd-fonts.jetbrains-mono
      ];

      fonts.fontconfig.defaultFonts = {
        sansSerif = [
          "Atkinson Hyperlegible Next"
          "Noto Sans Bengali"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif Bengali"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Bengali"
        ];
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        jack.enable = true;

      };

      hardware.keyboard.qmk.enable = true;
      hardware.keyboard.qmk.keychronSupport = true;
      services.udev.packages = [
        pkgs.sane-airscan
        pkgs.via
      ];
      environment.systemPackages = [
        pkgs.via
        pkgs.nixpkgs-manual
      ];

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 5 --keep-since 3d";
      };

      programs.nix-index-database.comma.enable = true;

      documentation.dev.enable = true;

    };
  meta.unfreeNames = [ "via" ];
}
