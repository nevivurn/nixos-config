{ inputs, lib, pkgs, ... }:

with inputs;

{
  imports = [
    (self + "/nixos/modules/nix.nix")
    (self + "/nixos/modules/users.nix")

    home-manager.nixosModules.home-manager

    (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Users

  users.users.nixos = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILA46OFhojJ+Bcbv5qJ3KZQhLtYKb/54V6Dk4KAUmt20 nevivurn@dziban"
    ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      pkgsUnstable = import nixpkgs-unstable {
        inherit (pkgs) system config;
      };
    })
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    openFirewall = true;
  };
  environment.enableAllTerminfo = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nixos.imports = [
      self.homeModules.default
      self.homeModules.shell
    ];
  };

  ## Other hardware-specific configuration

  # default (xz) is too slow
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
}