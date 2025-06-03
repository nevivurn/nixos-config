{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  hostname = "funi";
  machineId = "580b38632f5347f9eefb6ade40e88402";
in
{
  imports = [
    ./hardware-configuration.nix

    (inputs.self + "/nixos/modules/misc.nix")
    (inputs.self + "/nixos/modules/nix.nix")
    (inputs.self + "/nixos/modules/users.nix")

    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.pcengines-apu

    ./router.nix

    ./services/chrony.nix
    ./services/dns.nix
    ./services/hostapd.nix
    ./services/inadyn.nix
    ./services/mitm.nix
    ./services/monitoring.nix
    ./services/openssh.nix
  ];

  system.stateVersion = "24.05";

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/24c6e3bb-d225-4062-b4e7-4bf29dc05720";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  swapDevices = [ { device = "/dev/disk/by-partuuid/f19aaeb9-8fef-4d18-be7d-4196d1f99b0c"; } ];

  ## Boot

  boot.loader.grub.device = "/dev/disk/by-id/ata-TS256GMSA230S_I584340031";

  ## Networking

  environment.etc."machine-id".text = ''
    ${machineId}
  '';
  networking.hostId = builtins.substring 0 8 machineId;
  networking.hostName = hostname;
  networking.domain = "nevi.network";

  services.resolved.dnssec = "false";
  # services.resolved.fallbackDns does not support empty lists
  environment.etc."systemd/resolved.conf".text = lib.mkAfter ''
    FallbackDNS=
  '';

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Users

  users.users = {
    nevivurn = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = "/secrets/passwd-nevivurn";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUNr1fMh1l/hCfs/hjeT3AhBESCVq3QXgbQh/cTVRS3 nevivurn@taiyi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMglmE8YhvAD8g74xCisFbRD/caAMQ0c7UV9s4hTldGT nevivurn@alsafi"
      ];
    };
  };

  nixpkgs.overlays = [
    (final: prev: { pkgsUnstable = import inputs.nixpkgs-unstable { inherit (pkgs) system config; }; })
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    users.nevivurn = import ./home;
  };

  ## Other hardware-specific configuration

  hardware.enableRedistributableFirmware = true;

  # Patches adapted from OpenWRT:
  # Allow overriding firmware regulatory domain
  networking.wireless.athUserRegulatoryDomain = true;
  # Enable DFS-JP. As far as I can tell, my hardware supports DFS, and OpenWRT
  # enables it too.
  boot.kernelPatches = [
    {
      name = "enable-ath-DFS-JP";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        EXPERT = yes;
        CFG80211_CERTIFICATION_ONUS = yes;
        ATH10K_DFS_CERTIFIED = yes;
      };
    }
  ];

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;

  # Disk maintenance
  services.fstrim = {
    enable = true;
    interval = "monthly";
  };
  systemd.timers.fstrim.timerConfig.RandomizedDelaySec = "12h";

  services.smartd = {
    enable = true;
    defaults.monitored = "-a -o on -S on -s (S/../.././00|L/../15/./12)";
  };

  # we don't pull in nixos/modules/networking.nix
  environment.systemPackages = [ pkgs.wireguard-tools ];
}
