{ pkgs, inputs, ... }:

with inputs;

{
  imports = [
    ./boot.nix
    ./kavita.nix
    ./maintenance.nix
    ./misc.nix
    ./networking.nix
    ./nix.nix
    ./qbittorrent.nix
    ./users.nix

    home-manager.nixosModules.home-manager
    impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "23.05";

  nixpkgs.overlays = [
    self.overlays.default
    (final: prev: {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs) system config;
        overlays = [ self.overlays.default ];
      };
    })
  ];

  home-manager.sharedModules = [
    self.homeModules.default
    impermanence.nixosModules.home-manager.impermanence
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # required for impermanence
  programs.fuse.userAllowOther = true;
}
