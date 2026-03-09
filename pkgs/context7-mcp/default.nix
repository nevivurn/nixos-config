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
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "@upstash/context7-mcp@${finalAttrs.version}";
    hash = "sha256-6+VS18x+/AvAyWYNuEW+WMf29q7fvYu17MirRd5a0AY=";
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
    fetcherVersion = 1;
    hash = "sha256-rA7E21WwwfIPyb05hL7RIbnbC8wfW82DexApOa4Vt6g=";
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
})
