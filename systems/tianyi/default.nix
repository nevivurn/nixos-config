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

    "/mnt/athebyne" = {
      device = "athebyne.lan:/data";
      fsType = "nfs";
      options = [ "soft" ];
    };
  };
  swapDevices = [{
    device = "/dev/disk/by-id/nvme-eui.343433304b8054360025384500000001-part2";
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
          FirewallMark = 51820;
          RouteTable = 51820;
        };
        wireguardPeers = [{
          wireguardPeerConfig = {
            Endpoint = "alruba.nevi.network:6666";
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
          Domains = [ "~alruba.nevi.network" ];
        };
      };

      "30-wg-home" = {
        matchConfig.Name = "wg-home";
        linkConfig.RequiredForOnline = false;
        networkConfig = {
          Address = [
            "10.42.42.2/24"
            "fd5e:77c8:d76e:1::2/64"
          ];
          DNS = "192.168.1.1";
          Domains = [ "~." "~lan" ];
        };
        routingPolicyRules = [{
          routingPolicyRuleConfig = {
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

  # Keyboard setup
  services.xserver.xkbOptions = "ctrl:swapcaps,korean:ralt_hangul";
  console.useXkbConfig = true;

  # podman requires system-level config
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };
}
