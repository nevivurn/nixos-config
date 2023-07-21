{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "hosts";
  version = "3.13.13";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    hash = "sha256-wKVdNG3Uj1CdP35GDmRi7mIAGRJCWDzgwxC5Vd77XrA=";
  };

  patches = [ ./remove-invalid.patch ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 hosts $out/hosts
    runHook postInstall
  '';
}
