{ lib, config, ... }:

let cfg = config.services.audiobookshelf;
in {
  services.audiobookshelf = { enable = true; };

  services.caddy.virtualHosts."audiobookshelf.nevi.network".extraConfig = ''
    tls {
      dns cloudflare {env.CF_API_TOKEN}
      resolvers 1.1.1.1
    }

    @private remote_ip 192.168.2.0/24 fdbc:ba6a:38de::/64 10.42.42.0/24 fdbc:ba6a:38de:1::/64
    encode zstd gzip

    handle @private {
      reverse_proxy localhost:${builtins.toString cfg.port}
    }
  '';

  # hardening
  systemd.services.audiobookshelf.serviceConfig = {
    CapabilityBoundingSet = "";
    DynamicUser = true;
    LockPersonality = true;
    PrivateDevices = true;
    PrivateUsers = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
    SystemCallErrorNumber = "EPERM";
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/private/${cfg.dataDir}" ];
  };
}
