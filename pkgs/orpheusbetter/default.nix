{ lib
, fetchFromGitHub
, python3Packages
, makeWrapper
, flac
, lame
, mktorrent
, sox
}:

python3Packages.buildPythonPackage rec {
  pname = "orpheusbetter";
  version = "unstable-2022-05-18";

  src = fetchFromGitHub {
    owner = "ApexWeed";
    repo = "orpheusbetter-crawler";
    rev = "e3e9fea721fa271621e4b3a5cbcf81e5f028f009";
    hash = "sha256-sgcBDCpIItU3sIjmehxYS7EgNpcPviOVl12cjKIyrRk=";
  };
  format = "pyproject";

  patches = [ ./totp-login.patch ];

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = with python3Packages; [
    mechanicalsoup
    mutagen
    packaging
    setuptools
  ];

  postInstall = ''
    wrapProgram $out/bin/orpheusbetter \
      --prefix PATH : ${lib.makeBinPath  [ flac lame mktorrent sox ]}
  '';

  meta.mainProgram = "orpheusbetter";
}
