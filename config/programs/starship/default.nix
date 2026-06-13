{ ... }:

{
  # Starship reads directly from the nix store path via this env var.
  # Clean and simple — no copy needed, config is read-only "set and forget".
  home.sessionVariables.STARSHIP_CONFIG = "${../../../.config/starship.toml}";
}
