{ lib, pkgs, inputs, ... }:

with inputs;

let
  hostname = "taiyi";
  machineId = "62a136e793c240c588c6ddca2ed9d402";
in

{
  imports = [
    ./hardware-configuration.nix

    self.nixosModules.default
    self.nixosModules.graphical

    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-gpu-amd
  ];

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Lexar_500GB_SSD_J46138J003679-part1";
      fsType = "vfat";
      options = [ "noatime" ];
    };

    "/nix" = {
      device = "rpool/local/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/persist" = {
      device = "rpool/persist";
      fsType = "zfs";
      options = [ "zfsutil" ];
      neededForBoot = true;
    };
    "/persist/cache" = {
      device = "rpool/persist/cache";
      fsType = "zfs";
      options = [ "zfsutil" ];
      neededForBoot = true;
    };

    "/mnt/athebyne" = {
      device = "athebyne.lan:/data";
      fsType = "nfs";
      options = [ "soft" ];
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Lexar_500GB_SSD_J46138J003679-part2";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
    };
  }];

  ## Boot

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback rpool/local/root@empty
  '';

  ## Networking

  environment.etc."machine-id".text = "${machineId}\n";
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;

  systemd.network = {
    netdevs = {
      "30-wg-home" = {
        netdevConfig = {
          Name = "wg-home";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/persist/secrets/wg-home-priv";
        };
        wireguardPeers = [{
          wireguardPeerConfig = {
            Endpoint = "athebyne.lan:6666";
            PublicKey = "/3jJJC13Q4co0mFo/DXFp7pch1a7jk7C+dHKu+DxDUg=";
            PresharedKeyFile = "/persist/secrets/wg-home-athebyne-psk";
            AllowedIPs = [ "fd5e:77c8:d76e:1::/64" ];
          };
        }];
      };
    };

    networks = {
      "20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };

      "30-wg-home" = {
        matchConfig.Name = "wg-home";
        linkConfig.RequiredForOnline = false;
        networkConfig.Address = "fd5e:77c8:d76e:1::5/64";
      };
    };
  };

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Users

  users.users.nevivurn = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    passwordFile = "/persist/secrets/passwd-nevivurn";
  };
  home-manager.users.nevivurn = self.nixosModules.home-sway;

  ## Persistence

  environment.persistence = {
    "/persist".directories = [
      "/etc/nixos"
    ];
    "/persist/cache".directories = [
      "/home/nevivurn/.local/share/containers" # cannot be fuse
      "/root/.cache"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/timers"
      "/var/log"
    ];
  };

  ## Other hardware-specific configuration

  # podman requires system-level config
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  # cooler pump
  services.udev.packages = with pkgs; [ liquidctl ];
  systemd.services."liquidctl" = {
    description = "Configure pump speed curve";
    script = ''
      ${pkgs.liquidctl}/bin/liquidctl set pump speed 25 25 35 100
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
  };
}