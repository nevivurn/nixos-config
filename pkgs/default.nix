final: prev: {
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [ ./gnucash/krw-no-fraction.patch ];
  });

  # not sure about this one, but jellyfin tries to write weird files otherwise
  jellyfin-mpv-shim = prev.jellyfin-mpv-shim.overrideAttrs (_: {
    patches = [ ./jellyfin-mpv-shim/no-save-config.patch ];
  });

  # custom passmenu allowing generic tools for dmenu / xdotool alternatives
  passmenu = final.callPackage ./passmenu { };
}
