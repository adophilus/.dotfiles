# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, ond
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, pkgs-unstable, ... }: {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true;

  services.tlp = {
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  networking.hostName = "zenith";
  networking.usePredictableInterfaceNames = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true; # Easiest to use and most distros use this by default.
    dispatcherScripts = [{
      source = pkgs.writeText "add-gateway-alias" ''
        #!/usr/bin/env ${pkgs.bash}/bin/bash

        INTERFACE=$1
        EVENT=$2

        if [ "$EVENT" == "up" ]; then
          # Get the gateway IP address
          GATEWAY=$(ip route | grep default | grep $INTERFACE | awk '{print $3}')

          if [ -n "$GATEWAY" ]; then
            # Check if the alias already exists and remove it
            sudo sed -i '/gateway.lan/d' /etc/hosts

            # Add the new alias to /etc/host
            echo "$GATEWAY gateway.lan" | sudo tee -a /etc/hosts
          fi
        fi

        if [ "$EVENT" == "down" ]; then
          # Remove the alias when the interface goes down
          sudo sed -i '/gateway.lan/d' /etc/hosts
        fi
      '';
      type = "basic";
    }];
  };

  networking.extraHosts = ''
    127.0.0.1 ibank.lan
    127.0.0.1 podfi.lan
    127.0.0.1 tverza.lan
  '';

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * *      root   sleep 8 ; curl -s http://sync.afraid.org/u/RAgmoUBksWJ8UnoLL5p3oxKt/ >> /tmp/freedns_foodhut_mooo_com.log 2>/tmp/freedns_foodhut_mooo_com.err.log"
    ];
  };

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/8   trust
    '';
  };

  programs.nix-index.enable = true;
  programs.nix-index.enableBashIntegration = true;
  programs.nix-index.enableFishIntegration = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # services.logind.extraConfig = pkgs-unstable.lib.mkForce ''
  #   HandleLidSwitch=hibernate
  #   HandleLidSwitchExternalPower=hibernate
  # '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # services.displayManager = {
  #   sddm = {
  #     enable = true;
  #     wayland.enable = true;
  #   };
  # };

  # services.greetd.enable = true;

  # hardware.pulseaudio = {
  #   enable = true;
  #   package = pkgs-unstable.pulseaudioFull;
  #   extraConfig = "
  #     load-module module-switch-on-connect
  #   ";
  # };

  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs-unstable; [
  #     # ... # your Open GL, Vulkan and VAAPI drivers
  #     # vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
  #     # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
  #     # intel-media-sdk   # for older GPUs
  #     intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #     intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #     libvdpau-va-gl
  #   ];
  # };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.command-not-found.enable = false;

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        ControllerMode = "bredr";
      };
    };
  };

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" "bluetooth.target" ];
    bindsTo = [ "bluetooth.target" ];
    wantedBy = [ "bluetooth.target" ];
    serviceConfig.ExecStart = "${pkgs-unstable.bluez}/bin/mpris-proxy";
  };

  # programs.appimage.binfmt = true;

  programs.hyprland = {
    enable = true;
    # package =
    #   inputs.hyprland.packages.${pkgs-unstable.stdenv.hostPlatform.system}.hyprland;
    # portalPackage =
    #   inputs.hyprland.packages.${pkgs-unstable.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    # package = hyprland.packages."${pkgs-unstable.system}".hyprland;
    # xwayland.enable = true;
    # nvidiaPatches = true;
  };

  services.mysql = {
    enable = true;
    package = pkgs-unstable.mariadb;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  # hardware = {
  #   graphics = {
  #     enable = true;
  #     # driSupport = true;
  #     # driSupport32Bit = true;
  #   };
  #   # nvidia.modsetting.enable = true;
  # };
  # programs.gamemode.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vivaldi"
      "postman"
      "spotify"
      "google-chrome"
      "zoom"
      "code"
      "vscode"
      # "vscode-fhs"
      "discord"
      "obsidian"
    ];

  programs.fish.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs-unstable.wireshark;
  };

  virtualisation = {
    waydroid.enable = true;
    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adophilus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "wireshark" ];
    shell = pkgs-unstable.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs-unstable; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # services.tor = {
  #   enable = true;
  #   openFirewall = false;
  #   relay = {
  #     enable = false;
  #     role = "relay";
  #   };
  #   settings = {
  #     UseBridges = true;
  #     ClientTransportPlugin = "obfs4 exec ${pkgs-unstable.obfs4}/bin/lyrebird";
  #     Bridge = "obfs4 IP:ORPort [fingerprint]";
  #   };
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts =
    [ 2121 3000 5000 8000 8080 8081 8082 8100 ];
  networking.firewall.allowedUDPPorts =
    [ 2121 3000 5000 8000 8080 8081 8082 8100 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs-unstable; [ glibc gcc.cc.lib ];

  networking.nameservers = [ "8.8.8.8" ];
  networking.resolvconf.dnsExtensionMechanism = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
  system.autoUpgrade = {
    enable = false;
    channel = "https://nixos.org/channels/nixos-unstable";
    allowReboot = false;
  };
}

