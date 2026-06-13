{ lib, ... }:

{
  # Copy user_scripts from nix store to ~/user_scripts.
  # Hyprland references these via $scripts = $HOME/user_scripts.
  # Scripts must be executable.
  home.activation.copyUserScripts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -rf $HOME/user_scripts
    run cp -r ${../../../user_scripts} $HOME/user_scripts
    run chmod -R u+w $HOME/user_scripts
    run find $HOME/user_scripts -type f -name '*.sh' -exec chmod +x {} +
  '';
}
