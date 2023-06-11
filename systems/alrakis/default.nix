{ lib, inputs, ... }:

with inputs;

let
  hostname = "alrakis";
  machineId = "9cf94bc714b24f849a77ffb4d4c2e1c3";
in

{
  imports = [
    ./hardware-configuration.nix

    self.nixosModules.default

    nixos-hardware.nixosModules.lenovo-thinkpad
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-gpu-amd

    ./services/dns.nix
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
      device = "/dev/disk/by-id/ata-RevuAhn_900G_Blue_240GB_R9GBSV4240AI31KD0140-part1";
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
    device = "/dev/disk/by-id/ata-RevuAhn_900G_Blue_240GB_R9GBSV4240AI31KD0140-part2";
  }];

  ## Boot

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback rpool/local/root@empty
  '';

  ## Networking

  environment.etc."machine-id".text = "${machineId}\n";
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;
  networking.domain = "lan";
  networking.extraHosts = ''
    192.168.1.1 alruba.lan
    192.168.1.2 alrakis.lan
  '';

  systemd.network = {
    networks = {
      "20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          Address = "192.168.1.2/24";
          Gateway = "192.168.1.1";
          DNS = "127.0.0.1";
          IPv6AcceptRA = false;
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
    extraGroups = [ "wheel" ];
    passwordFile = "/persist/secrets/passwd-nevivurn";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
    ];
  };
  home-manager.users.nevivurn = self.nixosModules.home-shell;

  ## Persistence

  environment.persistence = {
    "/persist".directories = [
      "/etc/nixos"
    ];
    "/persist/cache".directories = [
      "/root/.cache"
      "/var/lib/nixos"
      "/var/lib/systemd/timers"
      "/var/log"
    ];
  };

  ## Other hardware-specific configuration

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = "50";
    STOP_CHARGE_THRESH_BAT0 = "80";
  };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };
}
