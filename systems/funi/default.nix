{ inputs, lib, pkgs, ... }:

with inputs;

let
  hostname = "funi";
  machineId = "580b38632f5347f9eefb6ade40e88402";
in

{
  imports = [
    ./hardware-configuration.nix

    (self + "/nixos/modules/misc.nix")
    (self + "/nixos/modules/nix.nix")
    (self + "/nixos/modules/users.nix")

    home-manager.nixosModules.home-manager
    nixos-hardware.nixosModules.pcengines-apu

    ./router.nix

    ./services/chrony.nix
    ./services/dns.nix
    ./services/hostapd.nix
    ./services/inadyn.nix
    ./services/mitm.nix
    ./services/monitoring.nix
    ./services/openssh.nix
  ];

  system.stateVersion = "23.11";

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/d1b748bd-7afd-aa4b-86f2-2ae58d294dd3";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  ## Boot

  boot.loader.grub.device = "/dev/disk/by-id/mmc-SA32G_0x2b2f415a";

  ## Networking

  environment.etc."machine-id".text = "${machineId}\n";
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ1U9//g+W2pRNdBaiADCMhAWlfWt3Ha1zwfR+iwMoZ nevivurn@tianyi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILA46OFhojJ+Bcbv5qJ3KZQhLtYKb/54V6Dk4KAUmt20 nevivurn@dziban"
      ];
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      pkgsUnstable = import nixpkgs-unstable {
        inherit (pkgs) system config;
      };
    })
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.nevivurn = import ./home;
  };

  ## Other hardware-specific configuration

  hardware.enableRedistributableFirmware = true;

  # Patches adapted from OpenWRT:
  # Allow overriding firmware regulatory domain
  networking.wireless.athUserRegulatoryDomain = true;
  # Enable DFS-JP. As far as I can tell, my hardware supports DFS, and OpenWRT
  # enables it too.
  boot.kernelPatches = [{
    name = "enable-ath-DFS-JP";
    patch = null;
    extraStructuredConfig = with lib.kernel; {
      EXPERT = yes;
      CFG80211_CERTIFICATION_ONUS = yes;
      ATH10K_DFS_CERTIFIED = yes;
    };
  }];

  # Unlike other systems, we have a *gasp* persistent root filesystem
  boot.tmp.cleanOnBoot = true;

  # we don't pull in nixos/modules/networking.nix
  environment.systemPackages = with pkgs; [ wireguard-tools ];
}
