{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd.user.paths.keepassxc-passonly = {
    Unit = {
      Description = "Run KeePassXC passonly service on file changes";
    };
    Path = {
      PathModified = "${config.home.homeDirectory}/KeePass/E1o3l.kdbx";
    };
    Install = {
      WantedBy = "paths.target";
    };
  };

  systemd.user.services.keepassxc-passonly = {
    Unit = {
      Description = "Run KeePassXC convert to passwordonly databases";
    };
    Service = {
      Type = "oneshot";
      ExecStart = ''
        sh -c 'echo "${KEEPASSXC_PASSWORD}" \
        | keepassxc-cli merge \
        ${config.home.homeDirectory}/KeePass/E1o3l_password_only.kdbx \
        ${config.home.homeDirectory}/KeePass/E1o3l.kdbx  \
        --no-password-from --yubikey-from 2:$(ykinfo -qs)'
      '';
    };
  };
}
