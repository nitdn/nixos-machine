{
  flake.modules.nixos.vps =
    { pkgs, config, ... }:
    {
      services.gitea-actions-runner = {
        package = pkgs.forgejo-runner;
        instances.codeberg-vps01 = {
          enable = true;
          name = "vps-01";
          tokenFile = config.sops.secrets.forgejo-runner-token.path;
          url = "https://codeberg.org/";
          labels = [
            "node-22:docker://node:22-bookworm"
            "nixos-latest:docker://nixos/nix"
            "runner:docker://runner"
          ];
          settings = {
            # runner.capacity = 2;
          };
        };
      };
      virtualisation.docker.enable = true;
      sops.secrets.forgejo-runner-token = { };
    };
  flake.modules.nixos.pc = {
    virtualisation.docker.enable = true;
  };
  perSystem =
    { pkgs, ... }:
    {
      packages.runner = pkgs.dockerTools.buildImage {
        name = "runner";
        tag = "latest";
        includeNixDB = true;
        copyToRoot = [
          (pkgs.buildEnv {
            name = "image-root";
            paths = [
              pkgs.nodejs
              pkgs.coreutils
              pkgs.nix
              pkgs.git
            ];
            pathsToLink = [
              "/bin"
            ];
          })
          pkgs.dockerTools.binSh
          pkgs.dockerTools.usrBinEnv
          pkgs.dockerTools.caCertificates
        ];
        runAsRoot = ''
          ${pkgs.dockerTools.shadowSetup}
          groupadd -r nixbld
          for n in $(seq 1 10); do useradd -c "Nix build user $n" \
          -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" \
          nixbld$n; done
        '';
        config.Env = [
          "NIX_PAGER=cat"
          ''
            NIX_CONFIG=
            experimental-features = nix-command flakes
            substituters = https://niri.cachix.org https://machines.cachix.org https://cache.nixos.org/
            trusted-public-keys = machines.cachix.org-1:imnXlKFUc4Iaedv6469v6TO37ruiNh6OfJN4le5bqdE= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=
          ''
          # A user is required by nix
          # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
          "USER=nobody"
        ];
      };
    };
}
