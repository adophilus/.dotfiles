{ lib, pkgs, ... }:

{
  # Installs gnupg + writes ~/.gnupg/gpg.conf. The keyring itself stays
  # mutable (imperative state) — we generate/import keys normally, so the
  # declarative programs.gpg.publicKeys option is deliberately NOT used.
  programs.gpg.enable = true;

  # gpg-agent caches unlocked passphrases; pinentry is its passphrase UI.
  # On macOS, pinentry_mac provides the GUI prompt (headless pinentry fails).
  services.gpg-agent = {
    enable = true;
    # pinentry.package = if pkgs.stdenv.isLinux then pkgs.pinentry else pkgs.pinentry_mac;
  };
}
