{ inputs, pkgs, ... }:

{
  imports = [
    (inputs.self + "/nixos/modules/misc.nix")
    (inputs.self + "/nixos/modules/nix.nix")
    (inputs.self + "/nixos/modules/users.nix")

    inputs.home-manager.nixosModules.home-manager

    (inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Users

  users.users.nixos = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMglmE8YhvAD8g74xCisFbRD/caAMQ0c7UV9s4hTldGT nevivurn@alsafi"
    ];
  };

  nixpkgs.overlays = [
    (final: prev: { pkgsUnstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; }; })
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    openFirewall = true;
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nixos.imports = [
      inputs.self.homeModules.default
      inputs.self.homeModules.shell
    ];
  };

  ## Other hardware-specific configuration

  # default (xz) is too slow
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
}
