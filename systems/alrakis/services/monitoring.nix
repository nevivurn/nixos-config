{ config, ... }:

{
  services.prometheus.exporters.node.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.prometheus.exporters.node.port ];
}
