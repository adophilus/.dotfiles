{
  lib,
  pkgs,
  ...
}:

{
  # AeroSpace reads ~/.aerospace.toml (home.file deploys it; HM backs up any
  # file the app generated on first run). Reload after rebuild:
  #   aerospace reload-config
  home.file.".aerospace.toml" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ../../../.config/aerospace/aerospace.toml;
  };
}
