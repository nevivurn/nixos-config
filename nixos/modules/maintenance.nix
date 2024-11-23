# maintenance tasks
{ lib, config, ... }:

lib.mkMerge [
  {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      randomizedDelaySec = "12h";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "monthly" ];
    };
    systemd.timers.nix-optimise.timerConfig.RandomizedDelaySec = lib.mkForce "12h";
  }

  (lib.mkIf config.boot.supportedFilesystems.zfs or false {
    services.zfs.autoScrub = {
      enable = true;
      interval = "monthly";
      randomizedDelaySec = "12h";
    };

    services.zfs.trim = {
      enable = true;
      interval = "monthly";
      randomizedDelaySec = "12h";
    };

    services.zfs.autoSnapshot = {
      enable = true;
      flags = "-k -p -u";
    };
  })
]
