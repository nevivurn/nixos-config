{ config, ... }:

let
  cfg = config.services.jellyfin;
in
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.jellyfin.serviceConfig = {
    CapabilityBoundingSet = "";
    ProtectProc = "invisible";
    ProcSubset = "pid";
    ProtectHome = true;
    ProtectSystem = "strict";
    ReadWritePaths = [ cfg.dataDir ];
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/jellyfin" ];
    "/persist/cache".directories = [ "/var/cache/jellyfin" ];
  };
}
