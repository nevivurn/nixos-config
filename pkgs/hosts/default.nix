{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.14.45";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-RC7vPporpYexMbWgfW8aDF9bKm9yq6ktOS6EY/u0oAk=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out hosts
    runHook postInstall
  '';
}
