{
  lib,
  pkgs,
  inputs,
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

  systemd.network = {
    netdevs = {
      "41-wg-proxy" = {
        netdevConfig = {
          Name = "wg41";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/persist/secrets/wg-home-wg41-priv";
          RouteTable = 4040;
          FirewallMark = 4040;
          RouteMetric = 4041;
        };
        wireguardPeers = [
          {
            Endpoint = "rtr01.pub.nevi.network:51820";
            PersistentKeepalive = 25;
            AllowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
            PublicKey = "Ph7zW70iiZC2hOcxSjI5SBZptUogFcGCTBFjWCvXGUQ=";
            PresharedKeyFile = "/persist/secrets/wg-home-wg41-alrakis-psk";
          }
        ];
      };
      "42-wg-proxy" = {
        netdevConfig = {
          Name = "wg42";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/persist/secrets/wg-home-wg42-priv";
          RouteTable = 4040;
          FirewallMark = 4040;
          RouteMetric = 4042;
        };
        wireguardPeers = [
          {
            Endpoint = "rtr02.pub.nevi.network:51820";
            PersistentKeepalive = 25;
            AllowedIPs = [
              "0.0.0.0/0"
              "::/0"
            ];
            PublicKey = "g50BReFg/OqPJFcVdLq280OrgfvoMMttMaOuvDIHdys=";
            PresharedKeyFile = "/persist/secrets/wg-home-wg42-alrakis-psk";
          }
        ];
      };
    };
    networks = {
      "20-wifi" = {
        matchConfig.Type = "wlan";
        networkConfig.DHCP = "yes";
        networkConfig.Domains = [ "~pub.nevi.network" ];
      };
      "41-wg-home" = {
        matchConfig.Name = "wg41";
        networkConfig = {
          Address = [
            "10.64.41.4/32"
            "fdbc:ba6a:38de:41::4/128"
          ];
          DNS = [
            "10.64.20.4"
            "10.64.20.5"
          ];
          DNSDefaultRoute = true;
          Domains = "~.";
        };
        routingPolicyRules = [
          {
            Family = "both";
            FirewallMark = 4040;
            InvertRule = true;
            Table = 4040;
            Priority = 4041;
          }
        ];
      };
      "42-wg-home" = {
        matchConfig.Name = "wg42";
        networkConfig = {
          Address = [
            "10.64.42.4/32"
            "fdbc:ba6a:38de:42::4/128"
          ];
          DNS = [
            "10.64.20.4"
            "10.64.20.5"
          ];
          DNSDefaultRoute = true;
          Domains = "~.";
        };
        routingPolicyRules = [
          {
            Family = "both";
            FirewallMark = 4040;
            InvertRule = true;
            Table = 4040;
            Priority = 4042;
          }
        ];
      };
    };
  };

  # allow wg traffic on weird return paths
  networking.firewall.extraReversePathFilterRules = ''
    udp sport 51820 accept
  '';

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
