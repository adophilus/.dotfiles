{
  lib,
  pkgs,
  ...
}:

# vimb — WebKitGTK vim browser, the light quick-lookup browser next to zen.
# Linux-only: WebKitGTK has no x86_64-darwin build (nadir never sees this).
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ pkgs.vimb ]; # 3.7.1 in nixpkgs-26.05

    # vimb keeps mutable state (history, cookies.db, queue, ...) INSIDE
    # ~/.config/vimb/ — so unlike ghostty/bottom we must NOT symlink the
    # whole dir to the read-only store. Link only the `config` file, which
    # vimb only reads; siblings stay plain writable files.
    home.file.".config/vimb/config".source = ../../../home/.config/vimb/config;
  };
}
