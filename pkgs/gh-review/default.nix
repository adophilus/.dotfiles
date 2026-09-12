{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "gh-review";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "NeedsSoySauce";
    repo = "gh-review";
    # no tagged releases yet — pinned to HEAD
    rev = "a217014f616d9095e7d8755fa19c7e599ebdebd9";
    hash = "sha256-bS1qp8bT5npoK6ldkDV+8IsKUMNSS6PYDDeXjtxpb0M=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Terminal UI for reviewing GitHub pull requests";
    homepage = "https://github.com/NeedsSoySauce/gh-review";
    license = lib.licenses.mit;
    mainProgram = "gh-review";
  };
}
