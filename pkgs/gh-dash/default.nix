# gh-dash — PR/issues dashboard TUI, a gh extension (dlvhdr/gh-dash).
# Packaged as goreleaser release binaries per platform — no Go toolchain,
# pinned by version + hash. gh does NOT discover gh-* on PATH (verified:
# `gh fakeext` → unknown command); it only executes
# ~/.local/share/gh/extensions/<name>/gh-<name> — config/programs/gh-dash
# links this binary there via xdg.dataFile.
{
  stdenv,
  fetchurl,
  lib,
}:

let
  version = "4.25.2";
  assets = {
    x86_64-linux = "linux-amd64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-amd64";
    aarch64-darwin = "darwin-arm64";
  };
  hashes = {
    x86_64-linux = "sha256-FUb4zrGT0L7S1O5EcOCop4n0zlx1ODsANzBcEl9bvOU=";
    aarch64-linux = "sha256-T+T8WbmEcDBlP7wSaPFW4T2zIY7OY/Duu7IRWqPDNm0=";
    x86_64-darwin = "sha256-ztKdFNnPSnUIyjp0ZvCmhn/paU/IxlzTVLyEL38ywYo=";
    aarch64-darwin = "sha256-oOeH71Z55F4Ixp7bNPJe2BGu/BQVfdCPVyHty1o+xnE=";
  };
in
stdenv.mkDerivation {
  pname = "gh-dash";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dlvhdr/gh-dash/releases/download/v${version}/gh-dash_v${version}_${assets.${stdenv.system}}";
    hash = hashes.${stdenv.system};
  };

  dontUnpack = true;
  installPhase = ''
    install -Dm555 $src $out/bin/gh-dash
  '';

  meta = {
    description = "gh extension to configure and view a dashboard of PRs and issues";
    homepage = "https://github.com/dlvhdr/gh-dash";
    license = lib.licenses.mit;
    mainProgram = "gh-dash";
    platforms = builtins.attrNames assets;
  };
}
