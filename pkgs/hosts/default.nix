{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.16";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-qhhr28Vl8xkszDLt21ThOuJ5A5vLRVhSlLrsN4rWGAk=";
  };

  patches = [ ./remove-invalid.patch ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 hosts $out/hosts
    runHook postInstall
  '';
}
