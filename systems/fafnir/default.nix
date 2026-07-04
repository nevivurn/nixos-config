{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  hostname = "fafnir";
  machineId = "abfee4d35ca65db726bc8fad5389ba71";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default

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
      device = "/dev/disk/by-partuuid/3e3d0f0f-6b9c-4f52-abc7-8e516009b4fd";
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

  ## Boot

  boot.zfs.devNodes = "/dev/disk/by-partuuid";
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
        ExecStart = "${lib.getExe pkgs.zfs} rollback rpool/local/root@empty";
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
        networkConfig.DHCP = "yes";
      };
    };
  };

  ## Basic config

  time.timeZone = "Etc/UTC";

  ## Users

  users.users.nevivurn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  home-manager.users.nevivurn = import ./home;

  ## Persistence

  environment.persistence = {
    "/persist".directories = [
      "/etc/nixos"
    ];
    "/persist/cache".directories = [
      "/root/.cache"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"
    ];
  };
}
