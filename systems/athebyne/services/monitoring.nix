{ config, pkgs, ... }:

{
  services.prometheus = {
    enable = true;
    enableReload = true;

    listenAddress = "localhost";
    retentionTime = "30d";

    scrapeConfigs = let exporters = config.services.prometheus.exporters;
    in [
      {
        job_name = "node_exporter";
        static_configs = [{
          targets = [
            "athebyne.nevi.network:${toString exporters.node.port}"
            "funi.nevi.network:${toString exporters.node.port}"
            "taiyi.nevi.network:${toString exporters.node.port}"
            "tianyi.home.nevi.network:${toString exporters.node.port}"
          ];
        }];
      }
      {
        job_name = "smartctl";
        static_configs = [{
          targets =
            [ "athebyne.nevi.network:${toString exporters.smartctl.port}" ];
        }];
      }
    ];

    exporters.node.enable = true;
    exporters.smartctl = {
      enable = true;
      devices = [
        "/dev/sda"
        "/dev/sdb"
        "/dev/sdc"
        "/dev/sdd"
        "/dev/sde"
        "/dev/sdf"
        "/dev/sdg"
        "/dev/sdh"
      ];
    };
  };

  services.grafana = {
    enable = true;
    provision = {
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";

        url = let prom = config.services.prometheus;
        in "http://${prom.listenAddress}:${toString prom.port}";

        isDefault = true;
        jsonData = {
          manageAlerts = false;
          timeInterval = let
            interval = config.services.prometheus.globalConfig.scrape_interval;
          in if interval != null then interval else "1m";
        };

      }];
      # broken for some reason, figure out later
      #dashboards.settings.providers = [{
      #  name = "node-exporter";
      #  allowUiUpdates = false;
      #  options.path = pkgs.fetchurl {
      #    name = "node-exporter.json";
      #    url = "https://grafana.com/api/dashboards/1860/revisions/33/download";
      #    hash = "sha256-lKT6RV47W32Ho+lMkFb19h9Ys1Ms7CtEqIGf7ED6B4E=";
      #  };
      #}];
    };
    settings = {
      server.http_addr = "localhost";
      server.root_url = "https://athebyne.nevi.network/grafana/";

      security.disable_initial_admin_creation = true;
      auth.disable_login_form = true;
      "auth.anonymous".enabled = true;
      "auth.anonymous".org_role = "Editor";
    };
  };

  environment.persistence = {
    "/persist".directories =
      [ "/var/lib/${config.services.prometheus.stateDir}" ];
  };
}
