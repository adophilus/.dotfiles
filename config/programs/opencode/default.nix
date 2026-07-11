{ config, ... }:
{
  programs.opencode = {
    enable = true;
    web = {
      enable = true;
      environmentFile = config.sops.secrets.adophilus.path;
      extraArgs = [
        "--hostname"
        "0.0.0.0"
        "--cors"
        "app-local://localhost"
      ];
    };
  };
}
