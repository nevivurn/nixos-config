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
  };

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/jellyfin"
    ];
    "/persist/cache".directories = [
      "/var/cache/jellyfin"
    ];
  };
}
