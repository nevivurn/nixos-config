{ config, pkgs, ... }:

{
  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

    settings = {
      server_name = "nevi.dev";
      public_baseurl = "https://matrix.nevi.network";

      listeners = [
        {
          port = 8008;
          x_forwarded = true;
          tls = false;
          resources = [{
            names = [ "client" "federation" ];
            compress = false;
          }];
        }
        {
          port = 8009;
          type = "metrics";
          tls = false;
          resources = [ ];
        }
      ];

      database.args = {
        cp_min = 5;
        cp_max = 10;
      };

      # same as default, but with loglevel WARNING
      log_config = pkgs.writeText "synapse-log_config.yaml" ''
        version: 1
        handlers:
          journal:
            class: systemd.journal.JournalHandler
            SYSLOG_IDENTIFIER: synapse
        root:
          level: WARNING
          handlers: [journal]
        disable_existing_loggers: false
      '';

      media_retention = {
        local_media_lifetime = "1y";
        remote_media_lifetime = "3w";
      };

      suppress_key_server_warning = true;
      enable_registration = false;
      report_stats = false;
      enable_metrics = true;
    };

    sliding-sync = {
      enable = true;
      environmentFile = "/persist/secrets/synapse-sliding-sync";
      settings.SYNCV3_SERVER = "https://matrix.nevi.network";
      settings.SYNCV3_BINDADDR = "localhost:8010";
    };
  };

  services.caddy.virtualHosts = {
    "matrix.nevi.network".extraConfig = ''
      encode zstd gzip
      reverse_proxy /_matrix/* localhost:8008
      reverse_proxy /_synapse/client/* localhost:8008
    '';
    "matrix-msc3575.nevi.network".extraConfig = ''
      encode zstd gzip
      reverse_proxy localhost:8010
    '';
  };

  services.prometheus.scrapeConfigs = [{
    job_name = "matrix-synapse";
    static_configs = let
      cfg = config.services.matrix-synapse;
      port = (builtins.elemAt
        (builtins.filter (l: l.type == "metrics") cfg.settings.listeners)
        0).port;
    in [{ targets = [ "athebyne.nevi.network:${builtins.toString port}" ]; }];
  }];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/matrix-synapse" ];
  };
}
