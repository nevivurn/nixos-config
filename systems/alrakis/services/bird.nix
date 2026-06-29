{
  services.bird = {
    enable = true;
    config = ''
      log syslog all;
      router id from "ens*";

      protocol device {
      };

      protocol kernel {
        learn;
        ipv6 {
          import all;
          export none;
        };
      };

      protocol static {
        ipv6;
        route 2a06:9801:7ce::/48 unreachable;
      };

      protocol bgp vultr_v6 {
        local as 219351;
        multihop 2;
        neighbor 2a0f:85c2:101::ff as 209735;

        ipv6 {
          import all;
          export filter {
            if source != RTS_STATIC then reject;
            accept;
          };
        };
      };
    '';
  };
}
