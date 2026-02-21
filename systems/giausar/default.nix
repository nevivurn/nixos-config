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

    ./services/openssh.nix
    ./services/nginx-sni-proxy.nix
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
              PresharedKeyFile = "/secrets/wg51-giausar-psk";
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
              PresharedKeyFile = "/secrets/wg52-giausar-psk";
            }
          ];
        };
      };
      networks = {
        "20-lan" = {
          matchConfig.Type = "ether";
          linkConfig.MTUBytes = builtins.toString mtu;
        };
        "51-wg-proxy" = {
          matchConfig.Name = "wg51";
          networkConfig.Address = [ "fdbc:ba6a:38de:51::3/64" ];
        };
        "52-wg-proxy" = {
          matchConfig.Name = "wg52";
          networkConfig.Address = [ "fdbc:ba6a:38de:52::3/64" ];
        };
      };
    };

  networking.firewall.allowedUDPPorts = [
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
  };
  home-manager.users.nevivurn = import ./home;

  ## Other hardware-specific configuration

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;
}
