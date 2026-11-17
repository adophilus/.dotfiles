# OxideZap — unofficial native WhatsApp desktop client in Rust (GPUI/wgpu
# front end, whatsmeow-style protocol layer). Unofficial protocol client:
# Meta ToS/ban risk applies; see upstream README. Linux-only: the
# home-manager module importing this is only in zenith's auto-discovered
# module list, so nadir never sees it.
#
# Upstream ships unsigned prebuilt binaries and has no versioned releases —
# only a rolling `nightly` tag whose tarball content changes. fetchzip pins
# today's tarball by hash; once built, the store copy is cached and rebuilds
# do NOT re-download (only a GC'd store or a new machine re-fetches, which
# then fails hash verification until you bump). Bump `version`, `url` and
# `hash` together to take a newer nightly:
#   nix-prefetch-url --unpack <url>   # base32 hash
#   nix hash to-sri --type sha256 <hash>
{
  stdenv,
  fetchzip,
  makeWrapper,
  symlinkJoin,
  alsa-lib,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  fontconfig,
  freetype,
  mesa,
  libglvnd,
}:
let
  version = "nightly-2026-11-13";

  # Libraries the binaries dlopen() at runtime — invisible to `readelf -d`,
  # so nix-ld's NEEDED-based resolution never sees them. They must arrive
  # via NIX_LD_LIBRARY_PATH (nix-ld reads it at launch). stdenv.cc.cc.lib
  # (libstdc++/libgcc_s) is included so the set is self-contained even when
  # launched from an env where the system-wide nix-ld library path is unset.
  runtimeLibs = symlinkJoin {
    name = "oxidezap-runtime-libs";
    paths = [
      alsa-lib
      libxcb
      libxkbcommon
      wayland
      vulkan-loader
      fontconfig
      freetype
      mesa
      libglvnd
      stdenv.cc.cc.lib
    ];
  };
in
stdenv.mkDerivation {
  pname = "oxidezap";
  inherit version;

  src = fetchzip {
    url = "https://github.com/oxidezap/client/releases/download/nightly/oxidezap-nightly-linux-x86_64.tar.gz";
    hash = "sha256-kAArX/BZ1iPkQZPfK0sW+MdJFhVON/1cYpuQTc3wGqY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # `oxidezap` (GPUI window) and `oxidezap-cli` auto-start `oxidezapd`
  # (session/store/tray daemon) "beside themselves" — same dir, which
  # $out/bin provides. The daemon owns the SQLite store and the WhatsApp
  # session; windows are thin clients over a per-user Unix socket, so
  # closing the window does not drop the connection.
  installPhase = ''
    runHook preInstall
    # fetchzip strips the single top-level dir, so the binaries are at $src root
    install -Dm755 oxidezap $out/bin/oxidezap
    install -Dm755 oxidezapd $out/bin/oxidezapd
    install -Dm755 oxidezap-cli $out/bin/oxidezap-cli
    # Launchers (rofi/wofi) list apps from freedesktop .desktop entries,
    # never raw binaries. StartupWMClass must match the Wayland app_id
    # (confirmed via `hyprctl clients`) so window rules can target it.
    install -Dm644 org.oxidezap.client.local.png \
      $out/share/pixmaps/org.oxidezap.client.local.png
    mkdir -p $out/share/applications
    cat > $out/share/applications/org.oxidezap.client.local.desktop <<EOF
[Desktop Entry]
Type=Application
Name=WhatsApp (OxideZap)
GenericName=WhatsApp Client
Comment=Unofficial native WhatsApp client
Exec=oxidezap
Icon=org.oxidezap.client.local
StartupWMClass=org.oxidezap.client.local
Categories=Network;InstantMessaging;
Terminal=false
EOF
    runHook postInstall
  '';

  # --prefix (not --set): nix-ld's system-configured library path must
  # survive, or the C++ runtime vanishes. VK_DRIVER_FILES: the vulkan loader
  # dlopens ICDs from FHS paths that don't exist on NixOS; point it at the
  # mesa Intel ICD that hardware.opengl exposes under /run/opengl-driver.
  postFixup = ''
    for bin in oxidezap oxidezapd oxidezap-cli; do
      wrapProgram $out/bin/$bin \
        --prefix NIX_LD_LIBRARY_PATH : "${runtimeLibs}/lib" \
        --set VK_DRIVER_FILES /run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json
    done
  '';

  meta.platforms = [ "x86_64-linux" ];
}
