{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.wireproxy ];

  # Create the background service
  systemd.services.wireproxy-main = {
    description = "Mullvad WireGuard Proxy (US Dallas)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.wireproxy}/bin/wireproxy -c /home/adophilus/.local/share/vpn/us-dal-wg-001.conf";

      Restart = "on-failure";
    };
  };
}
