final: prev:

import ./default.nix prev //

{
  # Remove fractional units for KRW
  gnucash = prev.gnucash.overrideAttrs (prev: {
    patches = prev.patches ++ [
      ./gnucash/krw-no-fraction.patch
      ./gnucash/extra-quote-sources.patch
    ];
  });

  firefox = if final.stdenv.isDarwin then final.callPackage ./firefox-darwin { } else prev.firefox;
}
