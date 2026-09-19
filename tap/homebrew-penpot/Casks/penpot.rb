# Personal tap — materialized into $HOMEBREW_LIBRARY/Taps/adophilus/homebrew-penpot
# by nix-homebrew (see darwin-configuration.nix). No git/GitHub needed.
cask "penpot" do
  version "0.25.0"
  sha256 "00a6065760cf62ea601ca07c396339f32fbe4ff15b06115773deed53ce6cf1c6"

  # x64 asset — this tap serves nadir (Intel). arm64: penpot-desktop-arm64.dmg
  url "https://github.com/author-more/penpot-desktop/releases/download/v#{version}/penpot-desktop-x64.dmg"
  name "Penpot Desktop"
  desc "Unofficial desktop application for the Penpot design tool"
  homepage "https://github.com/author-more/penpot-desktop"

  app "Penpot Desktop.app"
end
