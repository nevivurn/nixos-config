{
  lib,
  inputs,
  pkgs,
  ...
}:

let
  hostname = "alsafi";
  machineId = "3c2580b354ca43d5a06646c2df8d9938";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
    inputs.self.nixosModules.graphical

    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen5

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
      device = "/dev/disk/by-id/nvme-KBG6AZNV256G_LA_KIOXIA_5E7PSJXAZ12K-part1";
      fsType = "vfat";
      options = [
        "noatime"
        "fmask=0077"
        "dmask=0077"
      ];
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
      device = "/dev/disk/by-id/nvme-KBG6AZNV256G_LA_KIOXIA_5E7PSJXAZ12K-part2";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];

  boot.supportedFilesystems = [ "nfs" ];
  systemd.automounts = [
    {
      where = "/mnt/athebyne";
      automountConfig.TimeoutIdleSec = "5min";
      wantedBy = [ "multi-user.target" ];
    }
  ];
  systemd.mounts = [
    {
      after = [ "wg-quick-wg-home.service" ];
      type = "nfs";
      what = "athebyne.nevi.network:/data";
      where = "/mnt/athebyne";
      options = "soft";
    }
  ];

  ## Boot

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

  systemd.network.networks = {
    "20-wifi" = {
      matchConfig.Type = "wlan";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
        Domains = [ "~public.nevi.network" ];
      };
    };
  };

  networking.wg-quick.interfaces.wg-home = {
    privateKeyFile = "/persist/secrets/wg-home-priv";
    address = [
      "10.42.42.5/24"
      "fdbc:ba6a:38de:1::5/64"
    ];
    dns = [ "192.168.2.1" ];
    peers = [
      {
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "public.nevi.network:6666";
        presharedKeyFile = "/persist/secrets/wg-home-alsafi-psk";
        publicKey = "/3jJJC13Q4co0mFo/DXFp7pch1a7jk7C+dHKu+DxDUg=";
      }
    ];
  };

  networking.wireless.iwd.enable = true;
  networking.wireless.interfaces = [ "wlan0" ];
  # iwd automatically stops once dbus.service is stopped. Without this
  # configuration, iwd stops prematurely during shutdown, which causes delays
  # with nfs unmounting.
  systemd.services.iwd.after = [ "dbus.service" ];

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
      "/var/lib/iwd"
      "/var/lib/systemd/timers"
      "/var/log"
    ];
  };

  ## Other hardware-specific configuration

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Allow docking
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchDocked = "lock";
  };

  # Keyboard setup
  services.xserver.xkb.options = "ctrl:swapcaps,korean:ralt_hangul";
  console.useXkbConfig = true;

  # podman requires system-level config
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
