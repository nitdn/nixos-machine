{
  description = "A variety of machines powered by NixOS™";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    bizhub-225i = {
      url = "tarball+https://public.integration.yamayuri.kiku8101.com/publicdownload/download?fileId=B2C0B6D9-C563-4377-B77B-33BBAC4A5EC8";
      flake = false;
    };
    epson-202101w = {
      url = "file+https://download3.ebz.epson.net/dsc/f/03/00/15/15/02/f5cba2761f2f501363cdbf7e1b9b9879b0715aa5/epson-inkjet-printer-202101w-1.0.2-1.src.rpm";
      flake = false;
    };
    "jetpack.toml" = {
      url = "https://starship.rs/presets/toml/jetpack.toml";
      flake = false;
    };
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    direnv-instant.url = "github:Mic92/direnv-instant";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      ## optional overrides. Note that using a different version of nixpkgs
      # can cause issues, especially with python dependencies
      inputs.flake-parts.follows = "flake-parts";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    affinity-nix.url = "github:mrshmllow/affinity-nix";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    extra-substituters = [
      "https://machines.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "machines.cachix.org-1:imnXlKFUc4Iaedv6469v6TO37ruiNh6OfJN4le5bqdE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

}
