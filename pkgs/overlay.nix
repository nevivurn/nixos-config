final: prev:

import ./default.nix prev //

(if (prev.stdenv.isDarwin) then import ./default-darwin.nix prev else { }) //

{
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [
      ./gnucash/krw-no-fraction.patch
      ./gnucash/extra-quote-sources.patch
    ];
  });

  firefox = if prev.hostPlatform.isDarwin then final.callPackage ./firefox-darwin { } else prev.firefox;
}
