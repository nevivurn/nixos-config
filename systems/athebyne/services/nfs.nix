{ lib, config, ... }:

let
  cfg = config.services.nfs.server;
  allowedPorts = [
    111
    2049
  ]
  ++ lib.optionals (cfg.statdPort != null) [ cfg.statdPort ]
  ++ lib.optionals (cfg.lockdPort != null) [ cfg.lockdPort ]
  ++ lib.optionals (cfg.mountdPort != null) [ cfg.mountdPort ];
in
{
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
  };
  networking.firewall.allowedTCPPorts = allowedPorts;
  networking.firewall.allowedUDPPorts = allowedPorts;
}
