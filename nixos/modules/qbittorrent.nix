{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.qbittorrent;
in
{
  options = {
    services = {
      qbittorrent = {
        enable = lib.mkEnableOption "qBittorrent daemon";

        profileDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/qbittorrent";
        };
        saveDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/qbittorrent/downloads";
        };

        webuiPort = lib.mkOption {
          type = lib.types.port;
          default = 8080;
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "qbittorrent";
        };
        group = lib.mkOption {
          type = lib.types.str;
          default = "qbittorrent";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.qbittorrent-nox;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.profileDir}' 0770 ${cfg.user} ${cfg.group}"
      "d '${cfg.saveDir}' 0775 ${cfg.user} ${cfg.group}"
    ];

    systemd.services.qbittorrent = {
      after = [ "network.target" ];
      description = "qBittorrent Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        WorkingDirectory = cfg.profileDir;
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''
          ${cfg.package}/bin/qbittorrent-nox \
            --profile=${cfg.profileDir} \
            --relative-fastresume \
            --webui-port=${toString cfg.webuiPort}
        '';

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
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
        ReadWritePaths = [
          cfg.profileDir
          cfg.saveDir
        ];
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.webuiPort ];

    users.users = lib.mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        home = cfg.saveDir;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {
        name = "qbittorrent";
      };
    };
  };
}
