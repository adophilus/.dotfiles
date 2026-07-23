# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, ond
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/auto-suspend.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Power management
  services.system76-scheduler.settings.cfsProfiles.enable = true; # Better scheduling for CPU cycles - thanks System76!!!
  services.thermald.enable = true; # Enable thermald, the temperature management daemon. (only necessary if on Intel CPUs)
  services.power-profiles-daemon.enable = false; # Disable GNOMEs power management
  # services.tlp = {
  #   enable = true; # Enable TLP (better than gnomes internal power manager)
  #   settings = {
  #     CPU_BOOST_ON_AC = 1;
  #     CPU_BOOST_ON_BAT = 0;
  #     CPU_HWP_DYN_BOOST_ON_AC = 1;
  #     CPU_HWP_DYN_BOOST_ON_BAT = 0;
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #     PLATFORM_PROFILE_ON_AC = "performance";
  #     PLATFORM_PROFILE_ON_BAT = "low-power";
  #     START_CHARGE_THRESH_BAT0 = 75;
  #     STOP_CHARGE_THRESH_BAT0 = 81;
  #
  #     # Enable aggressive PCIe power management on battery (Saves ~0.5W - 1W)
  #     PCIE_ASPM_ON_BAT = "powersave";
  #
  #     # Put the SATA/NVMe drive links into low power states when unplugged
  #     SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
  #
  #     # Turn off Wi-Fi power-hungry features on battery
  #     WIFI_PWR_ON_BAT = "on";
  #
  #     # Enable USB Autosuspend (stops idle USB controllers from draining juice)
  #     USB_AUTOSUSPEND = 1;
  #     USB_EXCLUDE_AUDIO = 1; # Don't suspend USB audio devices to avoid crackle
  #
  #     # Power save for Intel onboard audio (1 = turn on power saving)
  #     SOUND_POWER_SAVE_ON_AC = 0;
  #     SOUND_POWER_SAVE_ON_BAT = 1;
  #
  #     # Turn off the audio controller completely after 1 second of inactivity
  #     SOUND_POWER_SAVE_CONTROLLER_ON_BAT = "Y";
  #
  #     # EXPLICIT PERIPHERAL PROTECTION:
  #     # This forces your mouse and keyboard to stay awake 100% of the time,
  #     # preventing any wonkiness, lag, or dropped keystrokes.
  #     # Don't stop specific usb devices (even when idle, e.g: keyboard)
  #     USB_DENYLIST = "10c4:0005 03f0:2f4a";
  #   };
  # };

  # services.i2pd = {
  #   enable = true;
  #   address = "127.0.0.1";
  #   proto = {
  #     http.enable = true;
  #     socksProxy.enable = true;
  #     httpProxy.enable = true;
  #     sam.enable = true;
  #     i2cp = {
  #       enable = true;
  #       address = "127.0.0.1";
  #       port = 7654;
  #     };
  #   };
  # };

  hardware.cpu.x86.msr.enable = true;

  services.undervolt = {
    enable = false;

    # Safe conservative baseline for Kaby Lake Refresh (i5-8250U)
    # Shaves voltage from both Core and Cache simultaneously
    coreOffset = -80; # CPU Core voltage reduction (mV)

    gpuOffset = -40; # Integrated Intel UHD Graphics reduction (mV)
    uncoreOffset = -40; # System Agent / Uncore reduction (mV)

    # Optional Thermal Guard (Keeps max heat under control)
    temp = 90; # Target max temperature in Celsius before throttling slightly
  };

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # pinentryPackage = pkgs.pinentry-curses;
    pinentryPackage = pkgs.pinentry-gnome3;
    # extraConfig = ''
    #   allow-loopback-pinentry
    # '';
    enableSSHSupport = true;
  };

  networking.hostName = "zenith";
  networking.usePredictableInterfaceNames = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true; # Easiest to use and most distros use this by default.
    dispatcherScripts = [
      {
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
      }
    ];
  };

  # Set your time zone.
  time.timeZone = "Africa/Lagos";

  # Enable cron service
  services.vnstat.enable = true;

  # programs.nix-index.enable = true;
  # programs.nix-index.enableBashIntegration = true;
  # programs.nix-index.enableFishIntegration = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false; # blocks PAM password fallback
    };
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # services.displayManager = {
  #   sddm = {
  #     enable = true;
  #     # wayland.enable = true;
  #   };
  # };

  # hardware.pulseaudio = {
  #   enable = true;
  #   package = pkgs-unstable.pulseaudioFull;
  #   # extraConfig = "
  #   #   load-module module-switch-on-connect
  #   # ";
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

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # programs.command-not-found.enable = false;

  hardware.intel-gpu-tools.enable = true;

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
    after = [
      "network.target"
      "sound.target"
      "bluetooth.target"
    ];
    bindsTo = [ "bluetooth.target" ];
    # wantedBy = [ "bluetooth.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs-unstable.bluez}/bin/mpris-proxy";
  };

  # programs.appimage.binfmt = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # package =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage = pkgs.xdg-desktop-portal-hyprland;
    # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    # xwayland.enable = true;
    # nvidiaPatches = true;
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
  };

  # tuigreet — minimal TUI greeter for greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs-unstable.tuigreet}/bin/tuigreet --cmd 'uwsm start default'";
      };
    };
  };

  # Enable ananicy
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp;
    settings = {
      apply_nice = true;
    };
  };

  # Earlyoom killer
  systemd.oomd.enable = false;
  services.earlyoom.enable = true;

  # Make nixos boot slightly faster by turning these off during boot
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;

  # No SIM card — disable mobile broadband management
  systemd.services.ModemManager.enable = false;

  # programs.xwayland.enable = true;

  services.udisks2.enable = true;

  # services.udiskie = {
  #   enable = true;
  #   settings = {
  #     # workaround for
  #     # https://github.com/nix-community/home-manager/issues/632
  #     program_options = {
  #       # replace with your favorite file manager
  #       file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
  #     };
  #   };
  # };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
    MOZ_DISABLE_RDD_SANDBOX = "1";
    MOZ_ENABLE_WAYLAND = "1";
    LIBVA_DRIVER_NAME = "iHD";

    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    XDG_SESSION_TYPE = "wayland";

    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  hardware = {
    graphics = {
      enable = true;
      # driSupport = true;
      # driSupport32Bit = true;
      extraPackages = with pkgs; [
        # vaapiIntel
        intel-vaapi-driver
        intel-media-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    # nvidia.modsetting.enable = true;
  };

  # programs.gamemode.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Larger buffers tuned for stability under CPU load (video calls).
    # 2048 @ 48kHz ≈ 43ms latency — imperceptible for calls, but much harder
    # to underrun than the previous 1024/512 config when the CPU is busy
    # decoding WebRTC video. Underruns = crackly audio for the remote party.
    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 2048;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 8192;
      };
    };

    wireplumber.extraConfig = {
      # ── Bluetooth: prefer AAC codec ──
      "50-bluetooth" = {
        "monitor.bluez.properties" = {
          "bluez5.codecs" = [
            "aac"
            "sbc"
            "sbc_xq"
          ];
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-hw-volume" = true;
        };
        "monitor.bluez.rules" = [
          {
            matches = [
              { "device.name" = "~bluez_card.*"; }
            ];
            actions.update-props = {
              "bluez5.auto-connect" = [
                "a2dp_sink"
                "hfp_hf"
              ];
              "bluez5.a2dp.aac.bitratemode" = 5;
            };
          }
        ];
      };

      # ── ALSA: bigger period + headroom to prevent hardware-level underruns,
      # and never suspend the device mid-call (resuming causes pops/clicks).
      "51-alsa-headroom" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input\\..*"; }
              { "node.name" = "~alsa_output\\..*"; }
            ];
            actions.update-props = {
              "api.alsa.period-size" = 1024;
              "api.alsa.headroom" = 8192;
              "session.suspend-timeout-seconds" = 0;
            };
          }
        ];
      };
    };
  };

  nixpkgs.config = {
    permittedInsecurePackages = [
      "electron-37.10.3"
    ];
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "vivaldi"
        "postman"
        "spotify"
        "google-chrome"
        "zoom"
        "code"
        "vscode"
        "steam"
        "steam-unwrapped"
        # "vscode-fhs"
        "discord"
        "obsidian"
        "osu-lazer"
      ];
  };

  programs.fish.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs-unstable.wireshark;
  };

  virtualisation = {
    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # docker = {
    #   enable = true;
    # };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adophilus = {
    isNormalUser = true;
    # extraGroups = [ "wheel" "wireshark" "docker" ];
    extraGroups = [
      "wheel"
      "wireshark"
      "networkmanager"
    ];
    shell = pkgs-unstable.fish;
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZPOgp7+K4/EoD42le6SrMyx0f1V9C7BTV9ofTZhZk9" # PC (Windows)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL2bq3qXrnIuRcH3zmJfbh14qGBTervXKVf6iZ5uQs+c" # vps (contabo)
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs-unstable; [
  #   # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   # wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # type db   user       address       method
      local  all  postgres                 peer          # superuser: sudo -u postgres psql
      local  all  all                      peer          # dev via socket: OS user -> role
      host   all  all       127.0.0.1/32   scram-sha-256 # TCP loopback: password required
      host   all  all       ::1/128        scram-sha-256
    '';
  };

  services.tor = {
    enable = true;
    client.dns.enable = true;
    settings.DNSPort = [
      {
        addr = "127.0.0.1";
        port = 53;
      }
    ];
    # resolved = {
    #   enable = true; # For caching DNS requests.
    #   fallbackDns = [ "" ]; # Overwrite compiled-in fallback DNS servers.
    # };
    openFirewall = false;
    relay = {
      enable = false;
      # role = "relay";
    };
    # settings = {
    #   UseBridges = true;
    #   ClientTransportPlugin = "obfs4 exec ${pkgs-unstable.obfs4}/bin/lyrebird";
    #   Bridge = "obfs4 IP:ORPort [fingerprint]";
    # };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      2121
      3000
      4096
      5000
      8000
      8080
      8081
      8100
    ]
    ++ [
      7236
      7250
    ]; # Miracast / RTSP control ports

    allowedUDPPorts = [
      2121
      3000
      5000
      8000
      8080
      8081
      8100
    ]
    ++ [
      7236
      5353
    ]; # Video streaming and mDNS/Discovery

    trustedInterfaces = [ "p2p-wl+" ]; # Allows Wi-Fi Direct/P2P interfaces
  };
  services.gnome.gnome-keyring.enable = true;

  # (Optional) Install Seahorse to manage your passwords via a GUI
  programs.seahorse.enable = true;
  programs.steam.enable = true;

  # Ensure the keyring is unlocked on login (works for most display managers)
  security.pam.services.login.enableGnomeKeyring = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    # Essential for Biome/OpenCode
    glibc
    gcc.cc.lib

    webkitgtk_4_1
    gtk3
    glib
    zlib
    nss
    nspr
    atk
    at-spi2-atk
    cups
    dbus
    expat
    libdrm
    libxkbcommon
    mesa
    pango
    cairo
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    libgbm
    libayatana-appindicator
    libsoup_3
    gdk-pixbuf
  ];

  networking.nameservers = [ "8.8.8.8" ];
  networking.resolvconf.dnsExtensionMechanism = false;
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSSEC = "true";
        Domains = [ "~." ];
        FallbackDns = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        DNSOverTLS = "true";
      };
    };
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50; # Compresses half your RAM to fit 2x the apps

  # Device to resume from on hibernation (the disk swap partition on sda5)
  boot.resumeDevice = "/dev/disk/by-uuid/c5fda66e-d506-41a8-abd4-e48b066abfc2";

  boot = {
    kernelParams = [
      "lru_gen.enabled=y"
    ];
    tmp.cleanOnBoot = true;
  };

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
