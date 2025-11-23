{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  hostname = "taiyi";
  machineId = "62a136e793c240c588c6ddca2ed9d402";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
    inputs.self.nixosModules.graphical

    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-intel

    ./services/backups.nix
    ./services/monitoring.nix
    ./services/openssh.nix
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
      device = "athebyne.nevi.network:/data";
      fsType = "nfs";
      options = [ "soft" ];
    };
  };
  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-Lexar_500GB_SSD_J46138J003679-part2";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];

  ## Boot

  boot.kernelParams = [ "iommu=pt" ];

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
          DNS = [
            "10.64.20.4"
            "10.64.20.5"
          ];
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
      "video"
    ];
    hashedPasswordFile = "/persist/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMglmE8YhvAD8g74xCisFbRD/caAMQ0c7UV9s4hTldGT nevivurn@alsafi"
    ];
  };
  home-manager.users.nevivurn = import ./home;

  ## Persistence

  environment.persistence = {
    "/persist".directories = [ "/etc/nixos" ];
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

  hardware.graphics.extraPackages = [ pkgs.intel-compute-runtime ];

  # cooler pump
  services.udev.packages = [ pkgs.liquidctl ];
  systemd.services."liquidctl" = {
    description = "Configure pump speed curve";
    script = ''
      ${lib.getExe pkgs.liquidctl} set pump speed 25 25 35 100
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
  };
}
