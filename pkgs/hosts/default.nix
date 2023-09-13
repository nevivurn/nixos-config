{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.14.4";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-RSCXsrvKjocvx4SMA3nHY9qtc3cMYf1gGImWm1+stl8=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
}
