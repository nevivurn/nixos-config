{ pkgs, ... }:

{
  # unbound as a simple, validating, recursive DNS server
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      server = {
        interface = [ "127.0.0.1@5353" ];
      };
    };
  };

  # dnsmasq as forwarding DNS + DHCP + some filtering
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;

    settings = {
      server = [
        "127.0.0.1#5353"
        "/lan/"
      ];
      listen-address = [
        "127.0.0.1"
        "192.168.1.2"
      ];
      domain = "lan";
      bind-interfaces = true;

      # public names are cached in unbound and client-side
      cache-size = 0;

      no-resolv = true;
      expand-hosts = true;
      localise-queries = true;

      addn-hosts = [ "${pkgs.hosts}/hosts" ];

      local-service = true;
      stop-dns-rebind = true;
      domain-needed = true;
      bogus-priv = true;
    };
  };
  systemd.services.dnsmasq = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  environment.persistence = {
    "/persist".directories = [
      "/var/lib/dnsmasq"
      "/var/lib/unbound"
    ];
  };
}
