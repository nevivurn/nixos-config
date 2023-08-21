{ pkgs, ... }:

let
  configFile = "/run/inadyn/inadyn.conf";

  configFilePre = pkgs.writeText "inadyn-config-pre" ''
    iface = enp1s0
    provider default@cloudflare.com {
      username = nevi.network
      password = @password@
      hostname = funi.nevi.network
    }
  '';

  configFileScript = ''
    ${pkgs.coreutils}/bin/install -m600 ${configFilePre} ${configFile}
    ${pkgs.replace-secret}/bin/replace-secret @password@ /secrets/cf-nevi-network ${configFile}
  '';
in

{
  users.users.inadyn = {
    isSystemUser = true;
    group = "inadyn";
  };
  users.groups.inadyn = { };

  systemd.services.inadyn = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";

      User = "inadyn";
      Group = "inadyn";
      ExecStartPre = pkgs.writeShellScript "inadyn-pre-start" configFileScript;
      ExecStart = "${pkgs.inadyn}/bin/inadyn -n --no-pidfile -f ${configFile}";

      RuntimeDirectory = "inadyn";
      CacheDirectory = "inadyn";

      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
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
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/cache/inadyn" ];
      RemoveIPC = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };
  };
}
