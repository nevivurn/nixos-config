{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.14";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-KMTm/F1CVu3bU0VR0OwbUCZraJNeKOsuT0tTpsDnTsU=";
  };

  patches = [ ./remove-invalid.patch ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 hosts $out/hosts
    runHook postInstall
  '';
}
