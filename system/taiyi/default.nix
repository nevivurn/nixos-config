{ lib, config, pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.common-cpu-amd-pstate
    nixos-hardware.common-gpu-amd
  ];

  system.stateVersion = "22.11";

  nixpkgs.config.allowUnfree = true;
  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  ## Filesystems

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/boot" = {
      device = "/dev/disk/by-id/nvme-Lexar_500GB_SSD_J46138J003679-part1";
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
    device = "/dev/disk/by-id/nvme-Lexar_500GB_SSD_J46138J003679-part2";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
      cipher = "aes-xts-plain64";
    };
  }];

  ## Boot

  boot.kernelParams = [ "amd_pstate.shared_mem=1" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback rpool/local/root@empty
  '';

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = { enable = true; editor = false; consoleMode = "0"; };

  ## Networking

  environment.etc."machine-id" = { text = "62a136e793c240c588c6ddca2ed9d402\n"; mode = "0644"; };
  networking.hostId = "62a136e7";
  networking.hostName = "taiyi";

  networking.useDHCP = false;
  networking.useNetworkd = true;
  services.resolved.dnssec = "false";

  systemd.network.networks."40-home" = {
    matchConfig = {
      Name = "enp42s0";
    };
    networkConfig = {
      Address = "192.168.1.10/24";
      Gateway = "192.168.1.1";
      DNS = [ "192.168.1.1" ];
      NTP = [ "192.168.1.1" ];
      LinkLocalAddressing = "no";
    };
  };

  ## Basic config

  time.timeZone = "Asia/Seoul";

  ## Maintenance

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
  systemd.timers.zfs-scrub.timerConfig.RandomizedDelaySec = "12h";
  services.zfs.trim = {
    enable = true;
    interval = "monthly";
  };
  systemd.timers.zpool-trim.timerConfig.RandomizedDelaySec = "12h";

  nix.gc = {
    automatic = true;
    dates = "monthly";
    persistent = true;
    randomizedDelaySec = "12h";
  };

  ## Users

  users.mutableUsers = false;
  users.users.nevivurn = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    passwordFile = "/persist/secrets/passwd-nevivurn";
  };

  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };
  security.polkit.enable = true;

  ## Persistence

  programs.fuse.userAllowOther = true;
  environment.persistence = {
    "/persist" = {
      directories = [
        "/etc/nixos"
      ];
    };
    "/persist/cache" = {
      directories = [
        "/home/nevivurn/.local/share/containers" # cannot be fuse
        "/root/.cache"
        "/var/lib/bluetooth"
        "/var/lib/systemd/timers"
        "/var/log"
      ];
    };
  };

  # Extra hardware config

  services.udev.packages = with pkgs; [ liquidctl ];
  hardware.opengl.enable = true;
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.gcr ];
  fonts.enableDefaultFonts = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
  hardware.bluetooth.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.dnsname.enable = true;
  };
}
