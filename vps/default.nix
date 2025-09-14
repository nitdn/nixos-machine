{ inputs, ... }:
{
  flake.nixosConfigurations.vps01 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.disko.nixosModules.disko
      ./configuration.nix
      inputs.nixos-facter-modules.nixosModules.facter
      inputs.sops-nix.nixosModules.sops
      inputs.authentik-nix.nixosModules.default
      {
        config.facter.reportPath =
          if builtins.pathExists ./facter.json then
            ./facter.json
          else
            throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ./vps/facter.json`?";
      }
    ];
  };
}
