{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "keybr-tui";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "y0sif";
    repo = "keybr-tui";
    rev = "v${version}";
    hash = "sha256-AORfoBISIhX33TQQrXad/NCLvUMPwz12k2Ac/cetbrc=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Adaptive terminal (TUI) typing trainer porting the keybr.com algorithm";
    homepage = "https://github.com/y0sif/keybr-tui";
    license = lib.licenses.mit;
    mainProgram = "keybr-tui";
  };
}
