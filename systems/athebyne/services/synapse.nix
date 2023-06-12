{ pkgs, ... }:
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

      enable_registration = false;
      report_stats = false;
      enable_metrics = true;
    };
  };

  services.caddy.virtualHosts."matrix.nevi.network" = {
    extraConfig = ''
      encode zstd gzip
      reverse_proxy /_matrix/* localhost:8008
      reverse_proxy /_synapse/client/* localhost:8008
    '';
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/matrix-synapse" ];
  };
}
