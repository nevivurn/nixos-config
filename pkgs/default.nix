final: prev: {
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [ ./gnucash/krw-no-fraction.patch ];
  });

  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = final.callPackage ./passmenu { };
}