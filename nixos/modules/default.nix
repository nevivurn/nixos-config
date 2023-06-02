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

  nixpkgs.overlays = [ self.overlays.default ];

  home-manager.sharedModules = [
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
