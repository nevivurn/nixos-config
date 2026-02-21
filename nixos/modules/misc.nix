{
  lib,
  config,
  pkgs,
  ...
}:

{
  services.irqbalance.enable = true;

  boot.kernel.sysctl = {
    # I have no idea what I'm doing, but this improves throughput significantly
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  environment.systemPackages = lib.mkIf (config.services.openssh.enable) [ pkgs.kitty.terminfo ];
}
