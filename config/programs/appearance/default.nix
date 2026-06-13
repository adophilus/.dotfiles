{ pkgs, ... }:

{
  # GTK dark mode + Qt theming + cursor.
  # These ensure consistent theming across GTK and Qt applications.

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
  };

  # Force dark color scheme via dconf (affects GNOME/GTK apps that read it)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
