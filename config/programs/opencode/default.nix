{ config, ... }:
{
  programs.opencode = {
    enable = true;
    web = {
      enable = true;
      environmentFile = config.sops.secrets.adophilus.path;
      extreArgs = [
        "--hostname"
        "0.0.0.0"
      ];
    };
  };
}
