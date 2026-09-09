# rusticity — AWS TUI with CloudWatch Logs Insights support
# (fuzzy log-group picker, query editor, SSO creds via aws-config default chain).
# Upstream: https://github.com/clumsy/rusticity — not in nixpkgs, builds from
# the crates.io tarball (workspace crate, release binaries exist but a source
# build keeps both hosts pure; one-time compile per host).
{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rusticity";
  version = "0.1.7";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;

  meta = {
    description = "Terminal UI for AWS, with CloudWatch Logs Insights query support";
    homepage = "https://github.com/clumsy/rusticity";
    license = lib.licenses.asl20;
    mainProgram = "rusticity";
    platforms = lib.platforms.unix;
  };
})
