{ lib, ... }:

let
  disks = [
    "ata-WDC_WUH721414ALE6L4_9JJ0DJWT"
    "ata-WDC_WUH721414ALE6L4_9JJ0BPGT"

    "ata-WDC_WD140EDGZ-11B2DA2_2CG52M7R"
    "ata-WDC_WUH721414ALE6L4_9JHNKSGT"

    "ata-WDC_WD140EDGZ-11B1PA0_9MHXTA2U"
    "ata-WDC_WD140EDGZ-11B2DA2_3WGH5ENK"

    "ata-WDC_WD140EDGZ-11B1PA0_Y6GV1N1C"
    "ata-WDC_WUH721414ALE6L4_9JHWP7AT"

    "nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNM0T210690N"
  ];
  dlen = builtins.length disks;

  modHr = a: lib.mod a 24;

  padz = n: s: if (builtins.stringLength s) >= n then s else padz n ("0" + s);
  pad2n = n: padz 2 (builtins.toString n);

in {
  services.smartd = {
    enable = true;
    autodetect = false;
    devices = lib.imap0 (i: v: {
      device = "/dev/disk/by-id/${v}";
      options = "-a -o on -S on -s ("
        + "S/../.././${pad2n (modHr (24 / dlen * i))}|"
        + "L/../15/./${pad2n (modHr (12 + 24 / dlen * i))})";
    }) disks;
  };
}
