{ lib, modulesPath, inputs, ... }:

with inputs;

let
  hostname = "funi";
  machineId = "580b38632f5347f9eefb6ade40e88402"; # TODO
in

{
  imports = [
    ./hardware-configuration.nix

    (self + "/nixos/modules/nix.nix")
    (self + "/nixos/modules/users.nix")

    (modulesPath + "/profiles/minimal.nix")
    home-manager.nixosModules.home-manager
    nixos-hardware.nixosModules.pcengines-apu

    ./router.nix
  ];

  system.stateVersion = "23.05";

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/TODO";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/TODO";
      fsType = "vfat";
      options = [ "noatime" ];
    };
  };

  ## Boot

  boot.loader.grub.device = "/dev/disk/by-id/TODO";

  ## Networking

  environment.etc."machine-id".text = "${machineId}\n";
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;
  networking.domain = "lan";

  services.resolved.dnssec = "false";
  # services.resolved.fallbackDns does not support empty lists
  environment.etc."systemd/resolved.conf".text = lib.mkAfter ''
    FallbackDNS=
  '';

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Users

  users.users.nevivurn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    passwordFile = "/persist/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
    ];
  };

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.nevivurn = import ./home;

  ## Other hardware-specific configuration

  environment.defaultPackages = [ ];
  programs.nano.syntaxHighlight = false;
  hardware.enableRedistributableFirmware = true;
}
