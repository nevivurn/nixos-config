{ lib, stdenv, fetchurl, undmg }:

stdenv.mkDerivation (finalAttrs: {
  pname = "firefox";
  version = "117.0.1";

  src = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${finalAttrs.version}/mac/en-US/Firefox%20${finalAttrs.version}.dmg";
    hash = "sha256-EaFT/ZfSB01zDs+CnIF0EKopASRJBjMtvx426Byi+RI=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv firefox.app $out/Applications
    runHook postInstall
  '';

  meta.platforms = lib.platforms.darwin;
})
