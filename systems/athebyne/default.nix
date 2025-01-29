{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

let
  hostname = "athebyne";
  machineId = "c41424cc1cd14395a864f52437bece7b";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
    ../../private/systems/athebyne/default.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd

    ./services/audiobookshelf.nix
    ./services/backups.nix
    ./services/caddy.nix
    ./services/jellyfin.nix
    ./services/kavita.nix
    ./services/monitoring.nix
    ./services/nfs.nix
    ./services/openssh.nix
    ./services/postgresql.nix
    ./services/qbittorrent.nix
    ./services/samba.nix
    ./services/smartd.nix
    ./services/synapse.nix
  ];

  ## Filesystems

  #   Bay 1    Bay 2
  #P1 9JJ0DJWT Y5JBTE9C
  #P2 2CG52M7R 9JHNKSGT
  #P3 9MHXTA2U 3WGH5ENK
  #P4 Y6GV1N1C 9JHWP7AT
  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNM0T210690N-part1";
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
  };
  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNM0T210690N-part2";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];

  ## Boot

  # pci passthrough
  boot.kernelParams = [
    "iommu=pt"
    "vfio-pci.ids=10de:2504,10de:228e"
    "video=efifb:off"
  ];
  boot.kernelModules = [
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
    "vfio_virqfd"
  ];

  boot.initrd.systemd = {
    enable = true;
    services."zfs-rollback" = {
      wantedBy = [ "initrd.target" ];
      requires = [ "zfs-import.target" ];
      after = [ "zfs-import.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.zfs}/bin/zfs rollback rpool/local/root@empty";
      };
    };
  };
  boot.zfs.extraPools = [ "dpool" ];

  ## Networking

  environment.etc."machine-id".text = ''
    ${machineId}
  '';
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;
  networking.domain = "nevi.network";
  networking.timeServers = [ ];

  # spare open port
  networking.firewall.allowedTCPPorts = [ 7777 ];
  networking.firewall.allowedUDPPorts = [ 7777 ];

  systemd.network = {
    netdevs = {
      "10-virbr" = {
        netdevConfig = {
          Name = "virbr0";
          Kind = "bridge";
        };
      };
    };

    networks = {
      "10-uplink" = {
        matchConfig.Type = "ether";
        networkConfig = {
          Bridge = "virbr0";
        };
      };

      "20-lan" = {
        matchConfig.Name = "virbr0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };
    };
  };

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
    extraGroups = [
      "wheel"
      "libvirtd"
    ];
    hashedPasswordFile = "/persist/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMglmE8YhvAD8g74xCisFbRD/caAMQ0c7UV9s4hTldGT nevivurn@alsafi"
    ];
  };
  home-manager.users.nevivurn = import ./home;

  users.users.media = {
    isSystemUser = true;
    home = "/data/media";
    group = "media";
  };
  users.groups.media = { };

  ## Persistence

  environment.persistence = {
    "/persist".directories = [
      "/etc/nixos"
      "/var/lib/libvirt"
      "/var/lib/qbittorrent"
    ];
    "/persist/cache".directories = [
      "/root/.cache"
      "/var/cache/libvirt"
      "/var/lib/nixos"
      "/var/lib/systemd/timers"
      "/var/log"
    ];
  };

  ## Other hardware-specific configuration

  # for hw accel
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.clr.icd
    ];
  };

  # podman requires system-level config
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  # VMs
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "virbr0" ];
    qemu.runAsRoot = false;
  };
}
