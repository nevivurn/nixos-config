{ lib, config, ... }:

let
  cfg = config.services.caddy;

  mitmHosts = {
    "i.redd.it" = ''
      header_up Accept "image/*"
    '';
  };
in {
  services.caddy = {
    enable = true;
    virtualHosts = lib.mapAttrs (name: value: {
      extraConfig = ''
        tls internal
        reverse_proxy {
          to https://${name}
          transport http {
            resolvers 127.0.0.1:5353
          }
          header_up -X-Forwarded-For
          header_up -X-Forwarded-Proto
          header_up -X-Forwarded-Host
          ${value}
        }
      '';
    }) mitmHosts;
  };

  services.dnsmasq.settings.cname = lib.mkAfter (lib.pipe mitmHosts [
    lib.attrNames
    (builtins.map (name: "${name},funi.nevi.network"))
  ]);

  systemd.services.caddy.serviceConfig = {
    CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateIPC = true;
    PrivateTmp = true;
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
}
