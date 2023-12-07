{ lib, pkgs, ... }:

{
  services.monero = {
    enable = true;
    extraConfig = ''
      no-igd=1
      zmq-pub=tcp://127.0.0.1:18083

      out-peers=32
      in-peers=64

      prune-blockchain=1
      sync-pruned-blocks=1

      confirm-external-bind=1
    '';

    rpc.address = "0.0.0.0";
  };

  systemd.services.monero.serviceConfig = {
    # disable RANDOMX_FLAG_JIT, otherwise segfaults for some reason
    Environment = "MONERO_RANDOMX_UMASK=8";

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
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_NETLINK" ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    StateDirectory = "monero";
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };

  systemd.services.monero-p2pool = {
    description = "Decentralized pool for Monero mining";
    after = [ "network.target" ];
    before = [ "monero.service" ];
    requires = [ "monero.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "monero-p2pool";
      Group = "monero-p2pool";
      ExecStart = "${pkgs.p2pool}/bin/p2pool --wallet 44nMXAaeWu26HnPSDXXNWWCcr2Bs9uBZtfd2r72VyjAbXKCFWBr6RMQdKpnYE8BWwR5SXwV7dJJHefSedd7rEsZTHQUUH3U --no-randomx --no-igd --mini";
      WorkingDirectory = "%S/monero-p2pool";
      Restart = "always";

      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      #NoNewPrivileges = true;
      PrivateDevices = true;
      #PrivateTmp = true;
      DynamicUser = true;
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
      #ProtectSystem = "strict";
      #RemoveIPC = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      StateDirectory = "monero-p2pool";
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };
  };

  networking.firewall.allowedTCPPorts = [ 18080 18081 37888 3333 ];

  environment.persistence = {
    "/persist/cache".directories = [
      "/var/lib/monero"
      "/var/lib/private/monero-p2pool"
    ];
  };
}
