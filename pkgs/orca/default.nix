# Orca (stablyai/orca) — Intel-mac build. Upstream (numtide/llm-agents.nix)
# only packages the arm64 zip (`packages.aarch64-darwin.orca`) and nadir is
# x86_64-darwin, so this fetches the x64 `Orca-<version>-mac.zip` release
# asset and mirrors their darwin installPhase verbatim (app bundle into
# $out/Applications, wrapper + CLI symlink into bin).
#
# Delete when upstream grows an x86_64-darwin package; until then, version
# bumps here are manual — swap the version in url and refresh the hash
# (`nix store prefetch-file <url>` / or just let a stale hash fail).
{
  fetchurl,
  stdenvNoCC,
  unzip,
  makeWrapper,
}:
stdenvNoCC.mkDerivation {
  pname = "orca";
  version = "1.4.268";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v1.4.268/Orca-1.4.268-mac.zip";
    hash = "sha256-1UH6pyyuvhKSViCOA29PFv/4MYgX04z5m0cfOMjKsPk=";
  };

  nativeBuildInputs = [ unzip makeWrapper ];
  sourceRoot = ".";
  # Keep the bundle's code signature intact (upstream does the same on darwin).
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications $out/bin
    cp -a Orca.app $out/Applications/
    makeWrapper $out/Applications/Orca.app/Contents/MacOS/Orca $out/bin/orca-ide
    ln -s $out/Applications/Orca.app/Contents/Resources/bin/orca $out/bin/orca
    runHook postInstall
  '';

  meta.mainProgram = "orca";
}
