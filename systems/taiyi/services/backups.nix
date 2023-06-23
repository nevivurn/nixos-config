{
  services.restic.backups.persist = {
    paths = [ "/persist" ];
    extraBackupArgs = [ "--exclude=/persist/cache" ];
    passwordFile = "/persist/secrets/restic-password";

    repository = "/mnt/athebyne/backups/taiyi";

    checkOpts = [ "--with-cache" ];
    pruneOpts = [
      "--keep-daily 30"
      "--keep-weekly 52"
      "--keep-monthly 48"
      "--keep-yearly 10"
    ];

    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
