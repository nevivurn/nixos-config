{ inputs, config, lib, pkgs, ... }:

with inputs;

{
  disabledModules = [ "${nixpkgs}/nixos/modules/services/web-apps/kavita.nix" ];
  imports =
    [ "${nixpkgs-unstable}/nixos/modules/services/web-apps/kavita.nix" ];

  services.kavita = {
    enable = true;
    package = pkgs.pkgsUnstable.kavita;
    tokenKeyFile = "/persist/secrets/kavita-token";
  };

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
