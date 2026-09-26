# Akira — native Linux (GTK3/Vala) design tool, upstream pre-alpha.
# Resurrected from nixpkgs (last packaged in nixos-23.11 as `akira`
# v0.0.16, later dropped). Upstream's GTK4 port is still unfinished
# (Dec 2025), so 0.0.16 remains the newest usable tag. Depends on the
# `pantheon` scope (granite) which still ships in 26.05.
{
  stdenv,
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  meson,
  ninja,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
  cairo,
  glib,
  goocanvas_3,
  gtk3,
  gtksourceview3,
  json-glib,
  libarchive,
  libgee,
  libxml2,
}:

stdenv.mkDerivation rec {
  pname = "akira";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "akiraux";
    repo = "Akira";
    rev = "v${version}";
    sha256 = "sha256-qrqmSCwA0kQVFD1gzutks9gMr7My7nw/KJs/VPisa0w=";
  };

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    glib
    goocanvas_3
    pantheon.granite
    gtk3
    gtksourceview3
    json-glib
    libarchive
    libgee
    libxml2
  ];

  mesonFlags = [ "-Dprofile=default" ];

  postPatch = ''
    chmod +x build-aux/meson/post_install.py
    patchShebangs build-aux/meson/post_install.py
  '';

  meta = with lib; {
    description = "Native Linux Design application built in Vala and GTK";
    homepage = "https://github.com/akiraux/Akira";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "com.github.akiraux.akira";
  };
}
