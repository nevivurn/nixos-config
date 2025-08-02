{ config, ... }:

{
  services.prometheus.exporters.node.enable = true;
  networking.firewall.interfaces."wg-proxy".allowedTCPPorts = [
    config.services.prometheus.exporters.node.port
  ];
}
