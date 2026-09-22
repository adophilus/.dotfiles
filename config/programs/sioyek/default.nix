# Sioyek — PDF reader for textbooks/papers, on both hosts (cross-platform:
# darwin build exists in nixpkgs 26.05, so zenith AND nadir get it — added to
# darwinHomeManagerModules in flake.nix too, since nadir doesn't auto-discover).
#
# Why over zathura: persistent highlights (sqlite DB, not the PDF file —
# embed via :embed_annotations if ever needed portable), portals (`p` —
# view ch1 in a side column while reading ch2), smart jump (click a
# reference → bibliography). Vim-ish defaults: gg/G, /n/N, m + `, b, t.
# The bindings below just add hjkl/d-u scrolling (zathura muscle memory);
# note j/k by default move the *visual mark* only.
{
  programs.sioyek = {
    enable = true;
    bindings = {
      move_down = "j";
      move_up = "k";
      screen_down = "d";
      screen_up = "u";
    };
  };
}
