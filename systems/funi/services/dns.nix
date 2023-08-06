{ pkgs, inputs, ... }:

with inputs;

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
      server = [ "127.0.0.1#5353" "/lan/" ];
      address = [
        "/funi.lan/192.168.2.1"
        "/funi.lan/2001:470:24:5b::1"
      ];
      interface = "br-lan";
      bind-interfaces = true;

      # public names are cached in unbound and client-side
      cache-size = 0;

      no-resolv = true;
      expand-hosts = true;
      localise-queries = true;
      proxy-dnssec = true;

      addn-hosts =
        let hosts = self.packages.${pkgs.system}.hosts; in
        [
          "${hosts}/hosts"
          "${hosts}/hosts-ipv6"
        ];
      no-hosts = true;

      stop-dns-rebind = true;
      domain-needed = true;
      bogus-priv = true;

      dhcp-range = [
        "192.168.2.100,192.168.2.254"
        "2001:470:24:5b::,2001:470:24:5b:ffff:ffff:ffff:ffff"
      ];
      enable-ra = true;

      domain = "lan";
      dhcp-fqdn = true;
    };
  };
  systemd.services.dnsmasq = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  networking.firewall.interfaces."br-lan" = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 67 547 ];
  };
}
