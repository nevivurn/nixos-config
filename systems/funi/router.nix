{
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    netdevs = {
      br-lan = {
        netdevConfig = {
          Name = "br-lan";
          Kind = "bridge";
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
      };
      "20-lan-bridge" = {
        matchConfig.Type = "ether";
        networkConfig.Bridge = "br-lan";
        linkConfig.RequiredForOnline = false;
      };
      "30-bridge" = {
        matchConfig.Type = "bridge";
        networkConfig = {
          IPForward = "yes";
          Address = [
            "192.168.2.1/24"
            "fdbc:ba6a:38de::1/64"
          ];
          DNS = [ "127.0.0.1" "::1" ];
          DHCP = "no";
          IPv6AcceptRA = false;
        };
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
            udp . 6666 : 192.168.2.10,
            tcp . 7777 : 192.168.2.10
          }
        }
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          iifname "br-lan" oifname "enp1s0" masquerade
        }
      }

      table inet filter {
        flowtable f {
          hook ingress priority filter; devices = { enp1s0, enp2s0, enp3s0, wlp4s0 };
        }

        chain rpfilter {
          type filter hook prerouting priority filter; policy accept;
          meta nfproto ipv4 udp sport . udp dport { 68 . 67, 67 . 68 } accept
          fib saddr . iif oif missing drop
        }

        chain forward {
          type filter hook forward priority filter; policy drop;

          meta l4proto { tcp, udp } flow offload @f
          ct state vmap { established : accept, related : accept, invalid : drop }

          icmpv6 type { router-renumbering, 139, 140 } drop
          icmpv6 type != { router-renumbering, 139, 140 } accept

          iifname vmap {
            br-lan : jump forward_lan,
            enp1s0 : jump forward_wan,
          }
        }

        chain forward_lan {
          oifname { "br-lan", "enp1s0" } accept
        }

        chain forward_wan {
          ct status dnat accept
          ip6 daddr fdbc:ba6a:38de::10 meta l4proto . th dport vmap {
            tcp . 80 : accept,
            tcp . 443 : accept,
            udp . 443 : accept,
            tcp . 5555 : accept,
            udp . 5555 : accept,
            udp . 6666 : accept,
            tcp . 7777 : accept
          }
        }

        chain input {
          type filter hook input priority filter; policy drop;

          ct state vmap { established : accept, related : accept, invalid : drop }
          iifname vmap { lo : accept, br-lan : jump input_lan, enp1s0 : jump input_wan }
        }

        chain input_lan {
          icmp type { echo-request } accept
          icmpv6 type != { nd-redirect, 139, 140 } accept

          meta l4proto . th dport vmap {
            tcp . 22 : accept,
            tcp . 53 : accept, udp . 53 : accept,
            udp . 67 : accept, udp . 547 : accept,
            udp . 123 : accept,
            tcp . 9100 : accept
          }
        }

        chain input_wan {
          icmp type { echo-request } accept
          icmpv6 type != { nd-redirect, 139, 140 } accept

          meta l4proto . th dport vmap {
            tcp . 22 : accept
          }
        }
      }
    '';
  };
}
