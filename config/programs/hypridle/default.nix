{ ... }:

{
  # Hypridle settings managed in Nix instead of external hypridle.conf.
  # To change timeouts or commands, edit this file and rebuild.
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "bash ~/.config/hypr/scripts/lock.sh";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          # Dim keyboard backlight (Intel laptop)
          timeout = 600;
          on-timeout = "brightnessctl -sd intel_backlight set 0";
          on-resume = "brightnessctl -dd intel_backlight";
        }
        {
          # Dim screen to 10%
          timeout = 600;
          on-timeout = "brightnessctl -s set '10%'";
          on-resume = "brightnessctl -r";
        }
        {
          # Screen off (DPMS)
          timeout = 660;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          # Lock session (30 min)
          timeout = 1800;
          on-timeout = "loginctl lock-session";
        }
        # Uncomment to enable suspend:
        # {
        #   timeout = 720;
        #   on-timeout = "systemctl suspend";
        # }
      ];
    };
  };
}
