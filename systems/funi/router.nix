{
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    netdevs = {
      "10-br-lan" = {
        netdevConfig = {
          Name = "br-lan";
          Kind = "bridge";
        };
      };
      "40-wg-home" = {
        netdevConfig = {
          Name = "wg-home";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/secrets/wg-home-priv";
          ListenPort = 6666;
        };
        wireguardPeers = builtins.map (x: { wireguardPeerConfig = x; }) [
          {
            # tianyi
            AllowedIPs = [
              "10.42.42.2/32"
              "fdbc:ba6a:38de:1::2/128"
            ];
            PublicKey = "JR9Zu+6QO8yBBE9WwbwEcdo6JVZ1pHsjb3P+mQIy3mY=";
            PresharedKeyFile = "/secrets/wg-home-tianyi-psk";
          }
          {
            # fafnir
            AllowedIPs = [
              "10.42.42.3/32"
              "fdbc:ba6a:38de:1::3/128"
            ];
            PublicKey = "W2634QLtmqji5pZzlDh5Z02KegcCf3uleQqbtctOsTk=";
            PresharedKeyFile = "/secrets/wg-home-fafnir-psk";
          }
          {
            # dziban
            AllowedIPs = [
              "10.42.42.4/32"
              "fdbc:ba6a:38de:1::4/128"
            ];
            PublicKey = "WAIgHHOWecTbkNv7dnwH98FDFjDmKIf1zno/+Lu+3ws=";
            PresharedKeyFile = "/secrets/wg-home-dziban-psk";
          }
          {
            # altais
            AllowedIPs = [
              "10.42.42.6/32"
              "fdbc:ba6a:38de:1::6/128"
            ];
            PublicKey = "F+Gz+s93TCYuFMYawdLF56gsjL6JNqOR7PglXbTZJgs=";
            PresharedKeyFile = "/secrets/wg-home-altais-psk";
          }
        ];
      };
      "50-wg-proxy" = {
        netdevConfig = {
          Name = "wg-proxy";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = "/secrets/wg-proxy-priv";
          ListenPort = 6667;
        };
        wireguardPeers = builtins.map (x: { wireguardPeerConfig = x; }) [
          {
            # rastaban
            AllowedIPs = [
              "10.42.43.2/32"
              "fdbc:ba6a:38de:2::2/128"
            ];
            PublicKey = "lU6yIAptWnX/kzYhdYucNYLgSya1xe8q+6Jvi6j7oQw=";
            PresharedKeyFile = "/secrets/wg-proxy-rastaban-psk";
            Endpoint = "rastaban.nevi.network:6667";
          }
          {
            # giausar
            AllowedIPs = [
              "10.42.43.3/32"
              "fdbc:ba6a:38de:2::3/128"
            ];
            PublicKey = "IhmbixqrWYfXtj3lHvFAXQknaN/HP8w/nqnc+tcH+1c=";
            PresharedKeyFile = "/secrets/wg-proxy-giausar-psk";
            Endpoint = "giausar.nevi.network:6667";
          }
        ];
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
        };
      };
      "40-wg-home" = {
        matchConfig.Name = "wg-home";
        networkConfig.Address = [
          "10.42.42.1/24"
          "fdbc:ba6a:38de:1::1/64"
        ];
      };
      "50-wg-home" = {
        matchConfig.Name = "wg-proxy";
        networkConfig.Address = [
          "10.42.43.1/24"
          "fdbc:ba6a:38de:2::1/64"
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
            tcp . 18080 : 192.168.2.10,
            # tcp . 37888 : 192.168.2.10,
          }
        }
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          iifname { "br-lan", "wg-home" } oifname "enp1s0" masquerade
          iifname { "br-lan", "wg-home" } oifname "wg-proxy" masquerade
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
            wg-home : jump forward_lan,
            enp1s0 : jump forward_wan,
            wg-proxy : jump forward_wan,
          }
        }

        chain forward_lan {
          oifname { "br-lan", "wg-home", "wg-proxy", "enp1s0" } accept
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
            wg-home : jump input_lan,
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
            udp . 6666 : accept,
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
          meta l4proto . th dport vmap {
            udp . 6666 : accept,
            udp . 6667 : accept,
          }
        }
      }
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
