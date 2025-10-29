{
  flake.modules.nixos.fish =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = map lib.lowPrio [
        pkgs.btop
        pkgs.curl
        pkgs.ghostty
        pkgs.gitMinimal
        pkgs.helix
        pkgs.openssl
      ];

      programs.fish.enable = true;
      programs.bash = {
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };
    };
}
