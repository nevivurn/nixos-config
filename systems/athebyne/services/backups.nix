{ pkgs, ... }:

{
  systemd.services."backup-sync" = {
    description = "Sync backup directories to cloud";
    environment = { CLOUDSDK_CORE_PROJECT = "nevi-dev-backups"; };
    script = ''
      ${pkgs.google-cloud-sdk}/bin/gcloud auth activate-service-account --key-file /data/keys/restic-unified-gcp
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/taiyi gs://nevi-backups-sp/taiyi
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/taiyi-old gs://nevi-backups-sp/taiyi-old
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/tianyi gs://nevi-backups-sp/tianyi
    '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers."backup-sync" = {
    description = "Sync backup directories to cloud daily";
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };

    wantedBy = [ "timers.target" ];
  };

  services.restic.backups.data = {
    paths = [ "/persist" "/data" ];
    extraBackupArgs = [
      "--exclude=/persist/cache"
      "--exclude=/data/backups"
      "--exclude=/data/torrents/incomplete"
      "--exclude=/data/vm"
    ];
    passwordFile = "/data/keys/restic-password";
    environmentFile = builtins.toString
      (pkgs.writeText "restic-gcp-creds" ''
        GOOGLE_APPLICATION_CREDENTIALS=/data/keys/restic-unified-gcp
      '');

    repository = "gs:nevi-backups-sp:athebyne";
    extraOptions = [ "gs.connections=10" ];

    checkOpts = [ "--with-cache" ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 5"
    ];

    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
  };
}
