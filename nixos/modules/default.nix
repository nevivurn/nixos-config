{ pkgs, inputs, ... }:

{
  imports = [
    ./boot.nix
    ./maintenance.nix
    ./misc.nix
    ./networking.nix
    ./nix.nix
    ./qbittorrent.nix
    ./users.nix

    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
  ];

  system.stateVersion = "24.05";

  nixpkgs.overlays = [
    inputs.self.overlays.default
    (final: prev: {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs) system config;
        overlays = [ inputs.self.overlays.default ];
      };
    })
  ];

  home-manager.sharedModules = [
    inputs.self.homeModules.default
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # required for impermanence
  programs.fuse.userAllowOther = true;
}
