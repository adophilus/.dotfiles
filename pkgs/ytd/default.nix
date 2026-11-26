{ pkgs, lib, ... }:
let
  name = "ytd";

  program = pkgs.writeShellApplication {
    name = "ytd";

    # yt-dlp deliberately NOT pinned: fast-moving tool, resolves from shell PATH
    runtimeInputs = with pkgs; [
      ffmpeg
    ];

    text = lib.fileContents ./ytd;
  };
in
pkgs.stdenv.mkDerivation {
  pname = name;

  version = "0.0.1";

  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    cp ${program}/bin/${name} $out/bin/
  '';
}
