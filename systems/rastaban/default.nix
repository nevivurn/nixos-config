{ lib, inputs, ... }:

let
  hostname = "rastaban";
  machineId = "ecad351b4ef642f08efe0328a1972d60";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default

    ./services/caddy.nix
    ./services/monitoring.nix
    ./services/openssh.nix
  ];

  ## Filesystems

  fileSystems."/" = {
    device = "/dev/disk/by-partuuid/TEST";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  swapDevices = [ { device = "/dev/disk/by-partuuid/52a23b9b-4eb7-4ced-b5a8-1bf671dad89e"; } ];

  ## Boot

  # force BIOS boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.device = "/dev/vda";

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
          PrivateKeyFile = "/persist/secrets/wg-proxy-priv";
          ListenPort = 6667;
          RouteTable = "main";
        };
        wireguardPeers = builtins.map (x: { wireguardPeerConfig = x; }) [
          {
            AllowedIPs = [
              "10.42.43.1/32"
              # specify all subnets for ipv6 as we don't NAT on ipv6
              "fdbc:ba6a:38de::/64" # lan
              "fdbc:ba6a:38de:1::/64" # wg-home
              "fdbc:ba6a:38de:2::/64" # wg-proxy
            ];
            PublicKey = "LpIGLOZ2phoWlVWRAY4Kun/ggfv3JUhBwd/I7QXdFWc=";
            PresharedKeyFile = "/persist/secrets/wg-proxy-rastaban-psk";
            Endpoint = "athebyne.nevi.network:6667";
          }
        ];
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
      "50-wg-home" = {
        matchConfig.Name = "wg-proxy";
        networkConfig.Address = [
          "10.42.43.2/24"
          "fdbc:ba6a:38de:2::2/64"
        ];
      };
    };
  };
  networking.firewall.allowedUDPPorts = [ 6667 ];

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
    ];
  };
  home-manager.users.nevivurn = import ./home;

  ## Other hardware-specific configuration

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;
}
