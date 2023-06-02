# maintenance tasks
{ lib, config, ... }:

lib.mkMerge [
  {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      randomizedDelaySec = "12h";
      options = "--delete-older-than 30d";
    };

    nix.optimise = {
      automatic = true;
      dates = [ "monthly" ];
    };
    systemd.timers.nix-optimise.timerConfig.RandomizedDelaySec = "12h";
  }

  (
    lib.mkIf (lib.any (fs: fs == "zfs") config.boot.supportedFilesystems)
      {
        boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

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

        services.zfs.autoSnapshot = {
          enable = true;
          flags = "-k -p -u";
        };
      }
  )
]

