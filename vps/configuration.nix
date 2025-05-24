{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  # cleanup configs
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:nitdn/nixos-machine";
  };
  networking.hostName = "vps01";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  programs.fish.enable = true;
  time.timeZone = "Asia/Kolkata";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.ghostty
  ];

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbQpjuFSDUDRO1j6gvxqI+zGsm4nRtXGxRbup8uzR8E ssmvabaa@tjmaxxer"
  ];

  system.stateVersion = "24.11";
}
