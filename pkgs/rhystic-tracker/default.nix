# Rhystic Tracker — Tauri v2 MTG Arena match tracker (Rust + React).
# Upstream ships no nix packaging; this bin-packages the official release
# artifacts for both hosts:
#
#   linux — x86_64 ELF tarball, mirroring the AUR rhystic-tracker-bin
#     PKGBUILD. The prebuilt ELF wants /lib64/ld-linux + /usr/lib paths, so
#     autoPatchelfHook rewrites the interpreter and RPATH onto the nix store
#     copies of its libs (buildInputs mirror the binary's DT_NEEDED list;
#     everything else arrives via propagation:
#     gtk3→gdk-pixbuf/pango/cairo, webkit→soup3/javascriptcore).
#
#   darwin — universal .app tarball, installed verbatim. Upstream signs
#     nothing; an unsigned app launches only while it carries no
#     com.apple.quarantine xattr. Nix store fetches never get one, which is
#     why this is a nix package and not a brew cask (brew quarantines →
#     unsigned builds hit the "damaged" dialog).
#
# Upgrade = bump `version`, refresh the linux hashes + the darwin hash
# (`nix hash convert --to sri sha256:<hex>` from the release SHA256SUMS.txt
# / sha256sum of the icon + LICENSE at the new tag).
{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  webkitgtk_4_1,
  gtk3,
  glib,
  dbus,
}:

let
  version = "1.9.3";
in
if stdenv.isDarwin then
  stdenv.mkDerivation {
    pname = "rhystic-tracker";
    inherit version;

    src = fetchurl {
      url = "https://github.com/Balthazzahr/Rhystic-Tracker/releases/download/v${version}/rhystic-tracker-macos-universal-app.tar.gz";
      hash = "sha256-GdRI62iSn33TV0MbnXDQHXGAtdZnIKuXL43xofXZwVs=";
    };

    # The tarball's single top-level dir IS the .app; without this, the
    # generic builder cd's into it and installPhase can't find it by name.
    sourceRoot = ".";

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -R "Rhystic Tracker.app" $out/Applications/
      runHook postInstall
    '';

    meta = with lib; {
      description = "Real-time MTG Arena match tracker and deck analysis for macOS";
      homepage = "https://github.com/Balthazzahr/Rhystic-Tracker";
      license = licenses.mit;
      platforms = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
  }
else
  stdenv.mkDerivation rec {
    pname = "rhystic-tracker";
    inherit version;

    src = fetchurl {
      url = "https://github.com/Balthazzahr/Rhystic-Tracker/releases/download/v${version}/rhystic-tracker-linux-x86_64.tar.gz";
      hash = "sha256-bljJGpb8IBwxQtxcfjFgcztwjX+a7QCEKyBMSTE7URs=";
    };

    # Icon + license live in the git tree at the same tag, not in the tarball.
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/Balthazzahr/Rhystic-Tracker/v${version}/src-tauri/icons/icon.png";
      hash = "sha256-+m3SXtv7eG2PHjD9ORCr50qxiss2uvmn9WBvr2p6lpg=";
    };

    licenseFile = fetchurl {
      url = "https://raw.githubusercontent.com/Balthazzahr/Rhystic-Tracker/v${version}/LICENSE";
      hash = "sha256-y/6AgrJT98hTRkcBDLr0qrr/JNTKrRdIojQRYfvxvpU=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [
      webkitgtk_4_1
      gtk3
      glib
      dbus
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 rhystic-tracker $out/bin/rhystic-tracker

      install -Dm644 ${icon} $out/share/icons/hicolor/512x512/apps/rhystic-tracker.png
      install -Dm644 ${licenseFile} $out/share/licenses/rhystic-tracker/LICENSE

      # Exec line copied verbatim from upstream packaging/rhystic-tracker.desktop
      # (x11 GDK backend + webkit compositing workaround + production marker).
      install -Dm644 /dev/null $out/share/applications/rhystic-tracker.desktop
      cat > $out/share/applications/rhystic-tracker.desktop <<'EOF'
      [Desktop Entry]
      Name=Rhystic Tracker
      GenericName=MTG Arena Tracker
      Comment=Real-time MTGA match tracking and deck analysis companion
      Exec=env GDK_BACKEND=x11 WEBKIT_DISABLE_COMPOSITING_MODE=1 RHYSTIC_ENV=production rhystic-tracker
      Icon=rhystic-tracker
      Terminal=false
      Type=Application
      Categories=Game;Utility;
      StartupNotify=false
      Keywords=mtg;magic;arena;tracker;rhystic;
      EOF

      runHook postInstall
    '';

    meta = with lib; {
      description = "Real-time MTG Arena match tracker and deck analysis for Linux";
      homepage = "https://github.com/Balthazzahr/Rhystic-Tracker";
      license = licenses.mit;
      mainProgram = "rhystic-tracker";
      platforms = [ "x86_64-linux" ];
    };
  }
