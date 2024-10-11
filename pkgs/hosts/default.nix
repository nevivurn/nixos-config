{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hosts";
  version = "3.14.120";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = finalAttrs.version;
    hash = "sha256-Aw9R7hHq2QM6SsFXYT/5bWKM5NZCXIal2fwl3vGf/kE=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
})
