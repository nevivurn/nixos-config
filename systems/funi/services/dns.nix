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
      server = [ "127.0.0.1#5353" "/nevi.network/" ];
      address = [
        "/funi.nevi.network/192.168.2.1"
        "/funi.nevi.network/fdbc:ba6a:38de::1"
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
        "fdbc:ba6a:38de:0:1::,fdbc:ba6a:38de::ffff:ffff:ffff:ffff"
      ];
      dhcp-host = [
        "92:ef:6d:2b:7b:cf,192.168.2.10,athebyne.nevi.network"
        "id:00:02:00:00:ab:11:df:85:50:1e:9b:2a:af:84,[fdbc:ba6a:38de::a],athebyne.nevi.network"
      ];
      enable-ra = true;

      domain = "nevi.network";
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
