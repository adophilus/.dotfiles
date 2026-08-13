{ config, lib, ... }:

{
  home.file.".pi/agent/themes" = {
    source = ../../../home/.config/pi/themes;
    recursive = true;
  };

  # settings.json is read/write by pi — using an activation script to
  # preserve user changes while initializing from dotfiles on fresh installs.
  home.activation.initPiSettings = (
    # Only copy if settings.json doesn't exist (fresh install)
    let
      settingsPath = "${config.home.homeDirectory}/.pi/agent/settings.json";
      dotfilesSettings = ../../../home/.pi/settings.json;
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "${settingsPath}" ]; then
        run mkdir -p $HOME/.pi/agent
        run cp ${dotfilesSettings} "${settingsPath}"
      fi
    ''
  );
}
