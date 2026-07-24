{
  feishu,
  stdenv,
  curl,
  jq,
  cacert,
  lib,
}:
let
  version = "7.66.11";

  # International Lark's .deb lives behind a short-lived (~1h) signed URL
  # returned by larksuite's package_info API. fetchurl can't pin a rotating
  # URL, so this fixed-output derivation resolves the link at build time and
  # downloads the deb. The deb bytes are deterministic per version, so the
  # hash contract holds — bump `version` and `outputHash` together on each
  # release (the API always returns latest).
  # platform=10 -> x86_64 deb, platform=12 -> aarch64 deb.
  lark-deb = stdenv.mkDerivation {
    name = "Lark-linux_x64-${version}.deb";
    nativeBuildInputs = [
      curl
      jq
      cacert
    ];
    impureEnvVars = [
      "http_proxy"
      "https_proxy"
      "HTTP_PROXY"
      "HTTPS_PROXY"
      "ALL_PROXY"
      "all_proxy"
      "NO_PROXY"
      "no_proxy"
    ];
    outputHashAlgo = "sha256";
    outputHashMode = "flat";
    outputHash = "sha256-6QCT/ed0dkER1FzD+HPobVeVb2RBuhnBBM6/wc8+6Ro=";
    buildCommand = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      link=$(curl -fsS 'https://www.larksuite.com/api/package_info?platform=10' | jq -r .data.download_link)
      curl -fsSL -o "$out" "$link"
    '';
  };
in
feishu.overrideAttrs (old: {
  inherit version;
  src = lark-deb;

  # The Lark deb mirrors Feishu's exactly, with "lark" in place of "feishu"
  # at every internal path (opt/bytedance/lark/, bytedance-lark, the .desktop
  # file, icons, rpath). One textual substitution rewrites the whole install
  # phase — verified against the deb's actual tar listing.
  installPhase = builtins.replaceStrings [ "feishu" ] [ "lark" ] old.installPhase;

  meta = old.meta // {
    mainProgram = "bytedance-lark";
    homepage = "https://www.larksuite.com/";
  };
})
