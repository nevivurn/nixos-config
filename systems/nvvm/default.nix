{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  hostname = "nvvm";
  machineId = "1b20a079b30d44dabb31cbb249fb7df6";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default

    ./services/openssh.nix
    ./services/ollama.nix
  ];

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/b976c2fa-a23a-46bf-b52c-ce3ebb82d615";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/cce0c13f-f755-4909-9f91-7e22b5e8f247";
      fsType = "vfat";
      options = [ "noatime" ];
    };
  };

  ## Boot

  ## Networking

  environment.etc."machine-id".text = ''
    ${machineId}
  '';
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;
  networking.domain = "nevi.network";
  networking.timeServers = [ ];

  systemd.network = {
    networks = {
      "20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };
    };
  };

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Users

  users.users.nevivurn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMglmE8YhvAD8g74xCisFbRD/caAMQ0c7UV9s4hTldGT nevivurn@alsafi"
    ];
  };
  home-manager.users.nevivurn = import ./home;

  ## Other hardware-specific configuration

  hardware = {
    nvidia = {
      open = true;
      nvidiaPersistenced = true;
    };
    graphics.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Module is not automatically loaded when open && no xserver
  # ref:
  # - https://github.com/NixOS/nixpkgs/issues/334180
  # - https://github.com/NixOS/nixpkgs/pull/334340
  boot.kernelModules = [ "nvidia_uvm" ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;
}
