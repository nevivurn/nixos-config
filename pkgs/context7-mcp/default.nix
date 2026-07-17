{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  fetchPnpmDeps,
  pnpm,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "context7-mcp";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "@upstash/context7-mcp@${finalAttrs.version}";
    hash = "sha256-Ea281W/CT/TfFNFMKV7xQzXnMo/25mCAB/Gs9ofyUU4=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm
    pnpmConfigHook
  ];

  buildInputs = [ nodejs ];

  pnpmWorkspaces = [ "@upstash/context7-mcp" ];
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    fetcherVersion = 3;
    hash = "sha256-l83CWEaDQ4dMo9UB0XKI+2Yueo7skU6B8ec4L4gVCm0=";
  };

  env.CI = true;

  buildPhase = ''
    runHook preBuild
    pnpm --filter @upstash/context7-mcp build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm install --offline --prod --filter @upstash/context7-mcp

    mkdir -p $out/lib
    cp -r node_modules $out/lib

    mkdir -p $out/lib/packages/mcp
    cp -r packages/mcp/{package.json,dist,node_modules} $out/lib/packages/mcp/

    mkdir -p $out/bin
    ln -s $out/lib/packages/mcp/dist/index.js $out/bin/context7-mcp

    runHook postInstall
  '';

  meta.mainProgram = "context7-mcp";
  passthru.nix-update-args = [
    "--version-regex"
    "^@upstash/context7-mcp@(.+)$"
  ];
})
