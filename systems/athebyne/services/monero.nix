{
  services.monero = {
    enable = true;
    extraConfig = ''
      no-igd=1
      no-zmq=1

      out-peers=32
      in-peers=64

      prune-blockchain=1
      sync-pruned-blocks=1
    '';
  };

  systemd.services.monero.serviceConfig = {
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
    RemoveIPC = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    StateDirectory = "monero";
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };

  networking.firewall.allowedTCPPorts = [ 18080 ];

  environment.persistence = {
    "/persist".directories = [ "/var/lib/monero" ];
  };
}
