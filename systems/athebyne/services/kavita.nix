{ lib, config, pkgs, ... }:

let cfg = config.services.kavita; in
{
  services.kavita = {
    enable = true;
    package = pkgs.kavita.overrideAttrs (prev: {
      frontend = prev.frontend.overrideAttrs {
        postPatch = ''
          sed -i 's|base href="/"|base href="${cfg.settings.BaseUrl}"|' src/index.html
        '';
      };
    });

    tokenKeyFile = "/persist/secrets/kavita-token";
    settings = {
      IpAddresses = "127.0.0.1,::1";
      BaseUrl = "/kavita/";
    };
  };

  systemd.services.kavita = {
    preStart = lib.mkBefore ''
      mkdir -p ${cfg.dataDir}/config
    '';
    serviceConfig = {
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
  };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/private/kavita" ];
  };
}
