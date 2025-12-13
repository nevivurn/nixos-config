{ config, pkgs, ... }:

let
  cfg = config.services.caddy;
in
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-Dvifm7rRwFfgXfcYvXcPDNlMaoxKd5h4mHEK6kJ+T4A=";
    };

    email = "yseong.p@gmail.com";

    virtualHosts."athebyne.nevi.network" = {
      extraConfig = ''
        tls {
          dns cloudflare {env.CF_API_TOKEN}
          resolvers 1.1.1.1
        }

        @private remote_ip 192.168.2.0/24 fdbc:ba6a:38de::/64 10.42.42.0/24 fdbc:ba6a:38de:1::/64
        encode zstd gzip

        redir /public /public/
        handle_path /public/* {
          root * /data/share/public
          file_server browse
        }

        handle @private {
          redir /torrents /torrents/
          route /torrents/* {
            uri strip_prefix /torrents
            reverse_proxy localhost:8080
          }

          redir /jellyfin /jellyfin/
          route /jellyfin/* {
            reverse_proxy localhost:8096
          }

          redir /grafana /grafana/
          route /grafana/* {
            uri strip_prefix /grafana
            reverse_proxy localhost:3000
          }
        }
      '';
    };
  };
  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = "/persist/secrets/cf-api-token";

    CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateIPC = true;
    PrivateTmp = true;
    #PrivateUsers = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    ReadWritePaths = [ cfg.dataDir ];
    RemoveIPC = true;
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/caddy" ];
  };
}
