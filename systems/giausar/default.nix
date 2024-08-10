{ lib, inputs, ... }:

let
  hostname = "giausar";
  machineId = "401e4bf51dd84326a81c99126117cee6";
in
{
  imports = [
    ./hardware-configuration.nix

    inputs.self.nixosModules.default
    ../../private/systems/giausar/default.nix

    ./services/monitoring.nix
    ./services/openssh.nix
  ];

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/a7c57033-d22d-493c-b02b-865aced48a86";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/mnt/slab" = {
      device = "/dev/disk/by-uuid/7af86277-fd69-4bc4-88c9-190256a2f0ed";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  swapDevices = [ { device = "/dev/disk/by-partuuid/00a97514-ce47-41c6-adce-91c1f4f61b2e"; } ];

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

  systemd.network =
    let
      mtu = 1450;
    in
    {
      netdevs = {
        "50-wg-proxy" = {
          netdevConfig = {
            Name = "wg-proxy";
            Kind = "wireguard";
            MTUBytes = builtins.toString (mtu - 80);
          };
          wireguardConfig = {
            PrivateKeyFile = "/secrets/wg-proxy-priv";
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
                # athebyne
                "192.168.2.10/32"
              ];
              PublicKey = "LpIGLOZ2phoWlVWRAY4Kun/ggfv3JUhBwd/I7QXdFWc=";
              PresharedKeyFile = "/secrets/wg-proxy-giausar-psk";
              Endpoint = "athebyne.nevi.network:6667";
            }
          ];
        };
      };
      networks = {
        "20-lan" = {
          matchConfig.Type = "ether";
          linkConfig.MTUBytes = builtins.toString mtu;
        };
        "50-wg-home" = {
          matchConfig.Name = "wg-proxy";
          networkConfig.Address = [
            "10.42.43.3/24"
            "fdbc:ba6a:38de:2::3/64"
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILA46OFhojJ+Bcbv5qJ3KZQhLtYKb/54V6Dk4KAUmt20 nevivurn@dziban"
    ];
  };
  home-manager.users.nevivurn = import ./home;

  ## Other hardware-specific configuration

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;
}
