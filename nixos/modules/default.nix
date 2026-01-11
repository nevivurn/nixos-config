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
  system.nixos.tags = with inputs.self; [ sourceInfo.shortRev or sourceInfo.dirtyShortRev ];

  nixpkgs.overlays = [
    (final: prev: {
      pkgsUnstable = import inputs.nixpkgs-unstable {
        inherit (pkgs) config;
        system = pkgs.stdenv.hostPlatform.system;
        overlays = [ inputs.self.overlays.default ];
      };
    })
    inputs.self.overlays.default
  ];

  home-manager.sharedModules = [
    inputs.self.homeModules.default
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
