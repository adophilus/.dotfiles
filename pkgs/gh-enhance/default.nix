# gh-enhance — gh-dash companion extension for managing PR GitHub Actions
# (dlvhdr/gh-enhance). Same packaging shape as gh-dash: goreleaser release
# binaries, linked into gh's extensions dir by config/programs/gh-enhance.
{
  stdenv,
  fetchurl,
  lib,
}:

let
  version = "0.7.0";
  assets = {
    x86_64-linux = "linux-amd64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-amd64";
    aarch64-darwin = "darwin-arm64";
  };
  hashes = {
    x86_64-linux = "sha256-f3XfPGOQOZVG4b6Up58aGLCpskG8KnGd31Q8XgeCLRM=";
    aarch64-linux = "sha256-TvWcP2p2uOVJVIy84JhBniCg9AfblFib2CPCIdRnmyE=";
    x86_64-darwin = "sha256-KzINzxL4nIgPwYv9jCRpr0t3etLT07u8qtSiABDEu58=";
    aarch64-darwin = "sha256-D26Wqt+BECycwcPeInRp0NLLfal5cm4u2bwH3Zi3t7E=";
  };
in
stdenv.mkDerivation {
  pname = "gh-enhance";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dlvhdr/gh-enhance/releases/download/v${version}/gh-enhance_v${version}_${assets.${stdenv.system}}";
    hash = hashes.${stdenv.system};
  };

  dontUnpack = true;
  installPhase = ''
    install -Dm555 $src $out/bin/gh-enhance
  '';

  meta = {
    description = "gh extension (gh-dash companion) to manage your PRs' GitHub Actions";
    homepage = "https://www.gh-dash.dev/companions/enhance/";
    license = lib.licenses.mit;
    mainProgram = "gh-enhance";
    platforms = builtins.attrNames assets;
  };
}
