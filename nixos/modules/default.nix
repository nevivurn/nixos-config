{ inputs, ... }:

with inputs;

{
  imports = [
    ./boot.nix
    ./maintenance.nix
    ./networking.nix
    ./nix.nix
    ./qbittorrent.nix
    ./users.nix

    home-manager.nixosModules.home-manager
    impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "23.05";

  nixpkgs.overlays = [ self.overlays.default ];

  home-manager.sharedModules = [
    self.nixosModules.home-default
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
