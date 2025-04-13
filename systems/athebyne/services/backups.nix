{ pkgs, ... }:

{
  systemd.services."backup-sync" = {
    description = "Sync backup directories to cloud";
    environment = {
      CLOUDSDK_CORE_PROJECT = "nevi-dev-backups";
    };
    script = ''
      ${pkgs.google-cloud-sdk}/bin/gcloud auth activate-service-account --key-file /data/keys/restic-unified-gcp
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/alsafi gs://nevi-backups-sp/alsafi
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/taiyi gs://nevi-backups-sp/taiyi
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/taiyi-old gs://nevi-backups-sp/taiyi-old
      ${pkgs.google-cloud-sdk}/bin/gsutil -m rsync -rd /data/backups/tianyi gs://nevi-backups-sp/tianyi
    '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers."backup-sync" = {
    description = "Sync backup directories to cloud daily";
    timerConfig = {
      OnCalendar = "weekly";
      RandomizedDelaySec = "12h";
      Persistent = true;
    };

    wantedBy = [ "timers.target" ];
  };

  services.restic.backups.data = {
    paths = [
      "/persist"
      "/data"
    ];
    extraBackupArgs = [
      "--exclude=/persist/cache"
      "--exclude=/persist/var/lib/libvirt/images"
      "--exclude=/data/backups"
      "--exclude=/data/torrents/incomplete"
      "--exclude=/data/vm"
    ];
    passwordFile = "/data/keys/restic-password";
    environmentFile =
      (pkgs.writeText "restic-gcp-creds" ''
        GOOGLE_APPLICATION_CREDENTIALS=/data/keys/restic-unified-gcp
      '').outPath;

    repository = "gs:nevi-backups-sp:athebyne";
    extraOptions = [ "gs.connections=10" ];

    checkOpts = [ "--with-cache" ];
    pruneOpts = [
      "--keep-weekly 52"
      "--keep-monthly 48"
      "--keep-yearly 10"
    ];

    timerConfig = {
      OnCalendar = "weekly";
      RandomizedDelaySec = "12h";
      Persistent = true;
    };
  };
}
