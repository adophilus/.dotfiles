{ config, lib, pkgs, ... }:

let
  # This creates the script as a package in the Nix store
  hypr-focus-suspend = pkgs.writeShellScriptBin "hypr-focus-suspend" ''
    # Apps to freeze when in background
    HEAVY_APPS=("zen" "discord" "spotify" "mpv" "sayonara")
    # Apps allowed to run in background ONLY if playing audio
    AUDIO_WHITELIST=("discord" "spotify" "mpv" "sayonara")

    is_playing_audio() {
        local app_name=$1
        # Check PulseAudio/PipeWire for an active 'RUNNING' stream from this app
        ${pkgs.pulseaudio}/bin/pactl list sink-inputs | \
        ${pkgs.gnugrep}/bin/grep -E "application.name = \"$app_name\"|resampled" -B 20 | \
        ${pkgs.gnugrep}/bin/grep -q "State: RUNNING"
    }

    handle_focus() {
        # Get active window class from Hyprland
        ACTIVE_CLASS=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.class')
        
        for APP in "''${HEAVY_APPS[@]}"; do
            if [ "$ACTIVE_CLASS" != "$APP" ]; then
                # If app is backgrounded, check if it's playing audio
                if [[ " ''${AUDIO_WHITELIST[@]} " =~ " ''${APP} " ]] && is_playing_audio "$APP"; then
                    ${pkgs.procps}/bin/pkill -SIGCONT -x "$APP" 2>/dev/null
                else
                    # Freeze the app (SIGSTOP)
                    ${pkgs.procps}/bin/pkill -SIGSTOP -x "$APP" 2>/dev/null
                fi
            else
                # App is focused, wake it up (SIGCONT)
                ${pkgs.procps}/bin/pkill -SIGCONT -x "$APP" 2>/dev/null
            fi
        done
    }

    # Listen to Hyprland event socket
    # We use socat to connect to the Unix socket provided by Hyprland
    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
        if [[ $line == activewindowv2* ]]; then
            handle_focus
        fi
    done
  '';
in
{
  # Define the systemd user service
  systemd.user.services.hypr-focus-suspend = {
    description = "Auto-suspend background apps with audio awareness";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${hypr-focus-suspend}/bin/hypr-focus-suspend";
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Make sure the required tools are available to the system
  environment.systemPackages = with pkgs; [
    socat
    jq
    procps
    pulseaudio
  ];
}
