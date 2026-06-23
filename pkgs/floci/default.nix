{
  stdenv,
  autoPatchelfHook,
  fetchurl,
  zlib,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "floci";
  version = "0.1.8";

  src = fetchurl {
    url = "https://github.com/floci-io/floci-cli/releases/download/${version}/floci-linux-amd64";
    hash = "sha256-68J+VRvxA4y3AznJ/LufoxpH7SHfrQRj9Omujp0ee64=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    zlib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/floci
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI for Floci — the free local cloud emulator for AWS and Azure";
    homepage = "https://github.com/floci-io/floci-cli";
    license = licenses.mit;
    mainProgram = "floci";
    platforms = [ "x86_64-linux" ];
  };
}
