{ pkgs, inputs, ... }:

with inputs;

{
  # unbound as a simple, validating, recursive DNS server
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings.server = {
      interface = [ "127.0.0.1@5353" ];

      num-threads = 4;
      msg-cache-slabs = 4;
      rrset-cache-slabs = 4;
      infra-cache-slabs = 4;
      key-cache-slabs = 4;
      outgoing-range = 200;

      jostle-timeout = 500;
      infra-keep-probing = true;

      # also sysctl, below
      so-rcvbuf = "4m";
      so-sndbuf = "4m";

      msg-cache-size = "128m";
      rrset-cache-size = "256m";

      serve-expired = true;
      serve-expired-ttl = 86400;
      serve-expired-client-timeout = 1800;
    };
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4 * 1024 * 1024;
    "net.core.wmem_max" = 4 * 1024 * 1024;
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

        "/tianyi.home.nevi.network/10.42.42.2"
        "/tianyi.home.nevi.network/fdbc:ba6a:38de:1::2"
      ];
      cname = [ "matrix.nevi.network,athebyne.nevi.network" ];
      interface = "br-lan";
      bind-interfaces = true;

      interface-name = [ "public.nevi.network,enp1s0/4" ];

      addn-hosts = [ "/secrets/dnsmasq-hosts" ];

      # public names are cached in unbound and client-side
      cache-size = 0;

      no-resolv = true;
      expand-hosts = true;
      localise-queries = true;
      proxy-dnssec = true;
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
        "a8:a1:59:6f:4d:54,192.168.2.11,athebyne-boot.nevi.network"
        "id:00:02:00:00:ab:11:df:85:50:1e:9b:2a:af:84,[fdbc:ba6a:38de::10],athebyne.nevi.network"
      ];
      enable-ra = true;

      dhcp-option =
        [ "option:ntp-server,0.0.0.0" "option6:ntp-server,[fd00::]" ];

      domain = "nevi.network";
      dhcp-fqdn = true;

      conf-file = [
        (pkgs.runCommand "dnsmasq-hosts" { } ''
          < ${self.packages.${pkgs.system}.hosts}/hosts \
              grep ^0.0.0.0 \
            | awk '{print $2}' \
            | tail -n+2 \
          > hosts
          awk '{print "local=/" $0 "/"}' hosts >> $out
          awk '{print "address=/" $0 "/0.0.0.0"}' hosts >> $out
        '').outPath
        "/secrets/dnsmasq-extra-conf"
      ];
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
