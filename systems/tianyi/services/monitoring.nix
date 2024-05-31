{ config, ... }:

{
  services.prometheus.exporters.node.enable = true;
  networking.firewall.interfaces.wg-home.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];
}
