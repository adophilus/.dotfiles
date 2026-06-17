{
  stdenv,
  rustPlatform,
  cargo,
  cacert,
  go,
  pkg-config,
  wayland,
  wayland-protocols,
  dbus,
  openssl,
  chafa,
  glib,
  fetchFromGitHub,
  buildGoModule,
  lib,
}:
let
  version = "unstable-2026-06-15";

  src = fetchFromGitHub {
    owner = "NullSeile";
    repo = "wstui";
    rev = "ba779e7";
    hash = "sha256-7ihps7NicEcQ0/VYPf92VLviWKvQmDyTrH8ImQsmsQ0=";
  };

  # Pre-build the Go c-archive (whatsmeow) offline with vendored deps
  goArchive = buildGoModule {
    pname = "wstui-whatsrust";
    inherit version src;
    sourceRoot = "${src.name or "source"}/whatsrust/lib";
    vendorHash = "sha256-IhIFsXaPpgflfl9Si/dHDGb05vpelyLqPcghEIsdgx4=";

    buildPhase = ''
      runHook preBuild
      go build -buildmode=c-archive -o libgo.a .
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp libgo.a $out/lib/
      cp libgo.h $out/lib/ 2>/dev/null || true
      runHook postInstall
    '';
  };

  # Fixed-output derivation: cargo vendor with network access (hash verified)
  # Works around nixpkgs fetch-cargo-vendor bug (crates.io 403 without User-Agent)
  vendoredCrates = stdenv.mkDerivation {
    name = "wstui-cargo-vendor";
    inherit src;
    nativeBuildInputs = [ cargo cacert ];

    dontFixup = true;
    dontPatchShebangs = true;

    impureEnvVars = [ "http_proxy" "https_proxy" "HTTP_PROXY" "HTTPS_PROXY" "ALL_PROXY" "all_proxy" "NO_PROXY" "no_proxy" ];

    buildPhase = ''
      export CARGO_HOME=$TMPDIR/cargo-home
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      cargo vendor --quiet vendor
    '';

    installPhase = ''
      cp -r vendor $out
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-9g0OKXuEcaOrZG08CdYMi93KhgbwnnQMoev6UmYO6zk=";
  };
in
rustPlatform.buildRustPackage {
  pname = "wstui";
  inherit version src;

  cargoVendorDir = "vendor";

  nativeBuildInputs = [
    go
    pkg-config
  ];

  buildInputs = [
    wayland
    wayland-protocols
    dbus
    openssl
    chafa
    glib
  ];

  # Symlink vendored crates into source tree after unpack
  # (cargoVendorDir expects a relative path in the source)
  postUnpack = ''
    ln -s ${vendoredCrates} $sourceRoot/vendor
  '';

  # Replace whatsrust/build.rs to link the pre-built Go archive
  preConfigure = ''
    cat > whatsrust/build.rs << 'EOF'
    fn main() {
        println!("cargo::rustc-link-search=native=${goArchive}/lib");
        println!("cargo::rustc-link-lib=static=go");
        println!("cargo:rerun-if-changed=build.rs");
    }
    EOF
  '';

  meta = with lib; {
    description = "WhatsApp client for the terminal with vim-style keybindings";
    homepage = "https://github.com/NullSeile/wstui";
    license = licenses.mit;
    mainProgram = "wstui";
    platforms = platforms.linux;
  };
}
