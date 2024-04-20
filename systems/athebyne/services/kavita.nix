{ inputs, config, lib, pkgs, ... }:

with inputs;

let cfg = config.services.kavita.settings;
in {
  disabledModules = [ "${nixpkgs}/nixos/modules/services/web-apps/kavita.nix" ];
  imports =
    [ "${nixpkgs-unstable}/nixos/modules/services/web-apps/kavita.nix" ];

  services.kavita = {
    enable = true;
    package = pkgs.pkgsUnstable.kavita;
    tokenKeyFile = "/persist/secrets/kavita-token";
    settings.IpAddresses = "127.0.0.1";
  };

  services.caddy.virtualHosts."kavita.nevi.network".extraConfig = ''
    tls {
      dns cloudflare {env.CF_API_TOKEN}
      resolvers 1.1.1.1
    }

    @private remote_ip 192.168.2.0/24 fdbc:ba6a:38de::/64 10.42.42.0/24 fdbc:ba6a:38de:1::/64
    encode zstd gzip

    handle @private {
      reverse_proxy localhost:${builtins.toString cfg.Port}
    }
  '';

  # hardening
  systemd.services.kavita.serviceConfig = {
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
    StateDirectory = "kavita";
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/private/kavita" ];
  };
}
