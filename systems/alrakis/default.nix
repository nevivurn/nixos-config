{ lib, inputs, ... }:

let
  hostname = "alrakis";
  machineId = "6dd24b01fdee45af9ec6e50b044512fa";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default

    ./services/monitoring.nix
    ./services/openssh.nix
    ./services/nginx-sni-proxy.nix
  ];

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/91c41fff-e1be-f048-baa0-fd512c0a05cf";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  ## Boot

  # force BIOS boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.device = "/dev/vdb";

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
      "50-wg-proxy" = {
        netdevConfig = {
          Name = "wg-proxy";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/secrets/wg-proxy-priv";
          ListenPort = 6667;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            AllowedIPs = [
              "10.42.43.0/24"
              # specify all subnets for ipv6 as we don't NAT on ipv6
              "fdbc:ba6a:38de::/64" # lan
              "fdbc:ba6a:38de:1::/64" # wg-home
              "fdbc:ba6a:38de:2::/64" # wg-proxy
              # athebyne
              "192.168.2.10/32"
            ];
            PublicKey = "LpIGLOZ2phoWlVWRAY4Kun/ggfv3JUhBwd/I7QXdFWc=";
            PresharedKeyFile = "/secrets/wg-proxy-alrakis-psk";
            Endpoint = "athebyne.nevi.network:6667";
            PersistentKeepalive = 25;
          }
        ];
      };
      "51-wg-proxy" = {
        netdevConfig = {
          Name = "wg51";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/secrets/wg51-priv";
          ListenPort = 6051;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            AllowedIPs = [ "fdbc:ba6a:38de:51::1/128" ];
            PublicKey = "nWRIJoXRWQ5h0Tu3irTVaAPwKda5xTBTz4J0CvijEV8=";
            PresharedKeyFile = "/secrets/wg51-alrakis-psk";
          }
        ];
      };
      "52-wg-proxy" = {
        netdevConfig = {
          Name = "wg52";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/secrets/wg52-priv";
          ListenPort = 6052;
          RouteTable = "main";
        };
        wireguardPeers = [
          {
            AllowedIPs = [ "fdbc:ba6a:38de:52::1/128" ];
            PublicKey = "7aVZW+ICYXqi62uRJupTqD+R+SMeX4plcu6gOTjrlSg=";
            PresharedKeyFile = "/secrets/wg52-alrakis-psk";
          }
        ];
      };
    };
    networks = {
      "20-lan" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = true;
        dhcpV6Config.WithoutRA = "solicit";
        routes = [
          {
            Gateway = "2a0f:85c2:101::1";
            Destination = "::/0";
          }
        ];
      };
      "50-wg-proxy" = {
        matchConfig.Name = "wg-proxy";
        networkConfig.Address = [
          "10.42.43.2/24"
          "fdbc:ba6a:38de:2::2/64"
        ];
      };
      "51-wg-proxy" = {
        matchConfig.Name = "wg51";
        networkConfig.Address = [ "fdbc:ba6a:38de:51::2/64" ];
      };
      "52-wg-proxy" = {
        matchConfig.Name = "wg52";
        networkConfig.Address = [ "fdbc:ba6a:38de:52::2/64" ];
      };
    };
  };

  networking.firewall.allowedUDPPorts = [
    6667
    6051
    6052
  ];

  ## Basic config

  time.timeZone = "Etc/UTC";

  ## Users

  users.users.nevivurn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMglmE8YhvAD8g74xCisFbRD/caAMQ0c7UV9s4hTldGT nevivurn@alsafi"
    ];
  };
  home-manager.users.nevivurn = import ./home;

  ## Other hardware-specific configuration

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;
}
