{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.14.17";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-fPMGNj1dXrbxJDxiC8U41NLz1vL5m3Ayw8uC1HJm4sU=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
}
