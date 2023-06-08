{ config, pkgs, ... }:

{
  services.prometheus = {
    enable = true;
    enableReload = true;

    listenAddress = "localhost";
    retentionTime = "30d";

    scrapeConfigs = [{
      job_name = "node_exporter";
      static_configs = [{
        targets =
          (
            let self = config.services.prometheus.exporters.node;
            in
            [ "${toString self.listenAddress}:${toString self.port}" ]
          )
          ++ [ "192.168.1.2:9100" ];
      }];
    }];

    exporters.node = {
      enable = true;
      listenAddress = "localhost";
    };
  };

  services.grafana = {
    enable = true;
    provision = {
      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";

        url = let prom = config.services.prometheus; in
          "http://${prom.listenAddress}:${toString prom.port}";

        isDefault = true;
        jsonData = {
          manageAlerts = false;
          timeInterval = let interval = config.services.prometheus.globalConfig.scrape_interval; in
            if interval != null then interval else "1m";
        };

      }];
      dashboards.settings.providers = [{
        name = "node-exporter";
        allowUiUpdates = false;
        options.path = pkgs.fetchurl {
          name = "node-exporter.json";
          url = "https://grafana.com/api/dashboards/1860/revisions/31/download";
          hash = "sha256-QsRHsnayYRRGc+2MfhaKGYpNdH02PesnR5b50MDzHIg=";
        };
      }];
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
    "/persist".directories = [
      "/var/lib/${config.services.prometheus.stateDir}"
    ];
  };
}
