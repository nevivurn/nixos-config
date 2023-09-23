{ lib, inputs, ... }:

with inputs;

let
  hostname = "tianyi";
  machineId = "438ba1d86084426fa0ceab1771e01586";
in

{
  imports = [
    ./hardware-configuration.nix

    self.nixosModules.default
    self.nixosModules.graphical

    nixos-hardware.nixosModules.dell-xps-13-9370

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
      device = "/dev/disk/by-id/nvme-eui.343433304b8054360025384500000001-part1";
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
  swapDevices = [{
    device = "/dev/disk/by-id/nvme-eui.343433304b8054360025384500000001-part2";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
    };
  }];

  boot.supportedFilesystems = [ "nfs" ];
  systemd.automounts = [{
    where = "/mnt/athebyne";
    automountConfig.TimeoutIdleSec = "5min";

    unitConfig.DefaultDependencies = false;
    before = [ "unmount.target" "remote-fs.target" ];
    after = [ "remote-fs-pre.target" "systemd-network-wait-online@wg\\x2dhome.service" ];
    requires = [ "systemd-network-wait-online@wg\\x2dhome.service" ];
    wantedBy = [ "multi-user.target" ];
    conflicts = [ "unmount.target" ];
  }];
  systemd.mounts = [{
    type = "nfs";
    what = "athebyne.nevi.network:/data";
    where = "/mnt/athebyne";
    options = "soft";
  }];

  ## Boot

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback rpool/local/root@empty
  '';

  ## Networking

  environment.etc."machine-id".text = "${machineId}\n";
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;
  networking.domain = "nevi.network";
  networking.timeServers = [ ];

  systemd.network = {
    netdevs = {
      "30-wg-home" = {
        netdevConfig = {
          Name = "wg-home";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/persist/secrets/wg-home-priv";
          FirewallMark = 51820;
          RouteTable = 51820;
        };
        wireguardPeers = [{
          wireguardPeerConfig = {
            Endpoint = "public.nevi.network:6666";
            PublicKey = "/3jJJC13Q4co0mFo/DXFp7pch1a7jk7C+dHKu+DxDUg=";
            PresharedKeyFile = "/persist/secrets/wg-home-athebyne-psk";
            AllowedIPs = [ "0.0.0.0/0" "::/0" ];
          };
        }];
      };
    };

    networks = {
      "20-wifi" = {
        matchConfig.Type = "wlan";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          Domains = [ "~public.nevi.network" ];
        };
      };

      "30-wg-home" = {
        matchConfig.Name = "wg-home";
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          Address = [
            "10.42.42.2/24"
            "fdbc:ba6a:38de:1::2/64"
          ];
          DNS = "192.168.2.1";
          NTP = "funi.nevi.network";
          Domains = [ "~." ];
        };
        routingPolicyRules = [{
          routingPolicyRuleConfig = {
            Family = "both";
            FirewallMark = 51820;
            InvertRule = true;
            Table = 51820;
          };
        }];
      };
    };
  };

  # rp mangling, copied from wg-quick
  boot.kernel.sysctl."net.ipv4.conf.all.src_valid_mark" = 1;
  networking.nftables.ruleset = lib.mkAfter ''
    table inet wg-rpmangle {
      chain premangle {
        type filter hook prerouting priority mangle;
        meta l4proto udp meta mark set ct mark
      }
      chain postmangle {
        type filter hook postrouting priority mangle;
        meta l4proto udp mark 51820 ct mark set mark
      }
    }
  '';

  networking.wireless.iwd.enable = true;
  networking.wireless.interfaces = [ "wlan0" ];

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
    extraGroups = [ "wheel" "video" ];
    passwordFile = "/persist/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
    ];
  };
  home-manager.users.nevivurn = import ./home;

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
      "/var/lib/iwd"
      "/var/lib/systemd/timers"
      "/var/log"
    ];
  };

  ## Other hardware-specific configuration

  boot.kernel.sysctl = {
    # Experimenting with bbr
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Keyboard setup
  services.xserver.xkbOptions = "ctrl:swapcaps,korean:ralt_hangul";
  console.useXkbConfig = true;

  # swaylock locks out otherwise
  security.pam.services.swaylock = { };

  # podman requires system-level config
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
