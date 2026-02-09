{
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    netdevs = {
      "10-lan-bond" = {
        netdevConfig = {
          Name = "bond0";
          Kind = "bond";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
        };
      };
      "10-br-lan" = {
        netdevConfig = {
          Name = "br-lan";
          Kind = "bridge";
        };
      };
      "31-br-lan-vlan" = {
        netdevConfig = {
          Name = "br-lan.200";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 200;
        };
      };
    };
    networks = {
      # WAN
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        dhcpV4Config = {
          UseDNS = false;
          UseNTP = false;
          UseHostname = false;
        };
        #dhcpV6Config = {
        #  UseDNS = false;
        #  UseNTP = false;
        #  UseHostname = false;
        #};
        ipv6AcceptRAConfig = {
          UseDNS = false;
        };
        cakeConfig.Bandwidth = "100M";
      };
      "20-lan-bond" = {
        matchConfig.Type = "ether";
        networkConfig.Bond = "bond0";
        linkConfig.RequiredForOnline = false;
      };
      "25-lan-bond-bridge" = {
        matchConfig.Name = "bond0";
        networkConfig.Bridge = "br-lan";
        linkConfig.RequiredForOnline = false;
      };
      "30-bridge" = {
        matchConfig = {
          Type = "bridge";
          Name = "br-lan";
        };
        networkConfig = {
          Address = [
            "192.168.2.1/24"
            "fdbc:ba6a:38de::1/64"
          ];
          DNS = [
            "127.0.0.1"
            "::1"
          ];
          DHCP = "no";
          IPv6AcceptRA = false;
          VLAN = [ "br-lan.200" ];
        };
      };
      "32-bridge-200" = {
        matchConfig.Name = "br-lan.200";
        networkConfig = {
          Address = [
            "10.64.200.3/24"
            "fdbc:ba6a:38de:200::3/64"
          ];
          DHCP = "no";
          IPv6AcceptRA = false;
        };
        routes = [
          # LEGACY -> new connectivity through ROUTER
          {
            Gateway = "10.64.200.4";
            Destination = "10.64.0.0/16";
          }
          {
            Gateway = "fdbc:ba6a:38de:200::4";
            Destination = "fdbc:ba6a:38de::/48";
          }
        ];
      };
    };
  };

  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    checkRuleset = false;
    ruleset = ''
      table ip nat {
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;

          iifname "enp1s0" dnat to meta l4proto . th dport map {
            tcp . 80 : 192.168.2.10,
            tcp . 443 : 192.168.2.10,
            udp . 443 : 192.168.2.10,
            tcp . 5555 : 192.168.2.10,
            udp . 5555 : 192.168.2.10,
          }
        }
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          iifname "br-lan" oifname "enp1s0" masquerade
        }
      }

      table inet filter {
        chain rpfilter {
          type filter hook prerouting priority filter; policy accept;
          meta nfproto ipv4 udp sport . udp dport { 68 . 67, 67 . 68 } accept
          fib saddr . iif oif missing drop
        }

        chain forward {
          type filter hook forward priority filter; policy drop;

          ct state vmap { established : accept, related : accept, invalid : drop }

          icmpv6 type { router-renumbering, 139, 140 } drop
          icmpv6 type != { router-renumbering, 139, 140 } accept

          iifname vmap {
            br-lan : jump forward_lan,
            br-lan.200 : jump forward_lan,
            enp1s0 : jump forward_wan,
          }
        }

        chain forward_lan {
          oifname { "br-lan", "br-lan.200", "enp1s0" } accept
        }

        chain forward_wan {
          ct status dnat accept
          ip6 daddr fdbc:ba6a:38de::10 meta l4proto . th dport vmap {
            tcp . 80 : accept,
            tcp . 443 : accept,
            udp . 443 : accept,
            tcp . 5555 : accept,
            udp . 5555 : accept,
          }
        }

        chain input {
          type filter hook input priority filter; policy drop;

          ct state vmap { established : accept, related : accept, invalid : drop }
          iifname vmap {
            lo : accept,
            br-lan : jump input_lan,
            br-lan.200 : jump input_lan,
            enp1s0 : jump input_wan,
          }
        }

        chain input_lan {
          icmp type { echo-request } accept
          icmpv6 type != { nd-redirect, 139, 140 } accept

          meta l4proto . th dport vmap {
            tcp . 22 : accept,
            tcp . 53 : accept, udp . 53 : accept,
            udp . 67 : accept, udp . 547 : accept,
            udp . 123 : accept,
            tcp . 7777 : accept, # spare open port
            tcp . 9100 : accept,
            tcp . 80 : accept,
            tcp . 443 : accept,
            udp . 443 : accept,
          }
        }

        chain input_wan {
          icmp type { echo-request } accept
          icmpv6 type != { nd-redirect, 139, 140 } accept
        }
      }
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
