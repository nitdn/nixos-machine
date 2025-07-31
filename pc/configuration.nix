# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  inputs,
  pkgs,
  username,
  ...
}:
let
in

{
  imports = [
    ./stubby.nix
    ./samba.nix
  ];

  nixpkgs.overlays = [
    inputs.helix.overlays.default
  ];

  # cleanup configs
  nix.optimise.automatic = true;
  nix.gc = {
    # WARN: Symlink store for home will not show up until you login
    # at which point its already too late
    # HACK: Turn off autogc indefinitely
    automatic = false;

    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nix.settings.substituters = [
    "https://cache.garnix.io"
  ];
  nix.settings.trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
  nix.settings.trusted-users = [
    "@wheel"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # Add additional package names here
      "steam"
      "steam-unwrapped"
      "hplip"
      "obsidian"
    ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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

  # Display manager configuration
  # Broken on homed users
  # services.displayManager.cosmic-greeter.enable = true;
  #
  services.xserver.displayManager.gdm.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.power-profiles-daemon.enable = true;

  # services.desktopManager.cosmic.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.extraLocaleSettings = {
    LC_ALL = "en_IN";
  };

  i18n.extraLocales = [
    "en_IN/UTF-8"
    "en_US.UTF-8/UTF-8"
    "bn_IN/UTF-8"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "Noto Sans Bengali"
    ];
    serif = [
      "Noto Serif Bengali"
    ];
    monospace = [
      "Noto Sans Bengali"
    ];
  };

  # Input methods
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      typing-booster
      openbangla-keyboard
    ];

    # type = "fcitx5";
    # fcitx5.waylandFrontend = true;
    # fcitx5.addons = with pkgs; [ fcitx5-openbangla-keyboard ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.system-config-printer.enable = true;
  programs.system-config-printer.enable = true;
  services.printing.logLevel = "debug";
  services.printing.drivers = with pkgs; [
    epson-escpr
    foomatic-db-ppds
    foomatic-filters
    (pkgs.callPackage ../bizhub-225i.nix { })

  ];

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
  services.udev.packages = with pkgs; [
    qmk-udev-rules
    sane-airscan
  ];

  # Install firefox.
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.gamemode.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # make distrobox work
  environment.etc = {
    "subuid" = {
      mode = "0644";
      text = ''
        ${username}:524288:65536
      '';
    };
    "subgid" = {
      mode = "0644";
      text = ''
        ${username}:524288:65536
      '';
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    adwaita-icon-theme
    bat
    du-dust
    eza
    gamescope
    ghostty
    git
    gparted
    helix
    ldns # drill
    mangohud
    openssl
    pwgen
    ripgrep
    sops
    trashy
    vulkan-tools
    wineWowPackages.stagingFull
  ];

  # security.wrappers = {
  #   # a setuid root program
  #   wine = {
  #     owner = "root";
  #     group = "root";
  #     capabilities = "cap_net_raw+eip";
  #     source = "${pkgs.wineWow64Packages.stagingFull}/bin/wine";
  #     permissions = "a+rx";
  #   };
  # };

  hardware.sane.enable = true;
  services.ipp-usb.enable = true;
  hardware.sane.extraBackends = [
    pkgs.hplipWithPlugin
    pkgs.sane-airscan
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.nh = {
    enable = true;
  };

}
