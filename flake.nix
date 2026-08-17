{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Kept solely for neovim-unwrapped 0.11.x (26.05 HEAD has 0.12+, breaks AstroNvim).
    nixpkgs-deprecated.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gws.url = "github:googleworkspace/cli";
    end4dots = {
      url = "github:end-4/dots-hyprland/510aa4096d814691c67805e5431cc40ec9e9d8a1";
      flake = false;
    };
    wifitui.url = "github:shazow/wifitui";
    zennotes.url = "github:ZenNotes/zennotes";
    hyprland.url = "github:hyprwm/Hyprland";
    nixgl.url = "github:guibou/nixGL";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # opencode: newer than nixpkgs 26.05 (which ships 1.15.10 — too old for
    # current MCP streamable-HTTP servers; z.ai endpoints 400 the old Accept
    # header). Local bun build (no upstream cache). Deliberately NO nixpkgs
    # follows: upstream pins the toolchain (bun/nodejs) their build needs;
    # ours is frozen at 26.05 (last Intel-darwin release) and would grow
    # stale under this fast-moving package. Repo moved sst→anomalyco.
    opencode.url = "github:anomalyco/opencode";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Installs Homebrew itself via Nix on macOS (sits under nix-darwin's
    # homebrew module, which manages the casks/brews list).
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    zen-browser = {
      url = "github:adophilus/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };

    # Open Design — local-first design tool (builds from source via dream2nix)
    open-design = {
      url = "github:nexu-io/open-design";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hypr-dynamic-cursors = {
    #   url = "github:VirtCode/hypr-dynamic-cursors";
    #   inputs.hyprland.follows =
    #     "hyprland"; # to make sure that the plugin is built for the correct version of hyprland
    # };
  };

  outputs =
    inputs@{
      home-manager,
      nixpkgs-deprecated,
      nixpkgs,
      nixpkgs-unstable,
      end4dots,
      wifitui,
      gws,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgsParams = {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-37.10.3"
          ];
        };
      };
      pkgs-deprecated = import nixpkgs-deprecated pkgsParams;
      pkgs = import nixpkgs pkgsParams;
      pkgs-unstable = import nixpkgs-unstable pkgsParams;
      wstui-pkg = pkgs.callPackage ./pkgs/wstui/default.nix { };
      floci-pkg = pkgs.callPackage ./pkgs/floci/default.nix { };
      ytd-pkg   = pkgs.callPackage ./pkgs/ytd/default.nix { };
      # Built from pkgs-unstable so its `feishu` base + buildInputs resolve
      # consistently (feishu is not in stable nixpkgs at this version).
      lark-pkg  = pkgs-unstable.callPackage ./pkgs/lark/default.nix { };

      # Open Design daemon (from the upstream flake, builds from source)
      open-design-pkg = inputs.open-design.packages.${system}.default;

      homeManagerProgramsDir = ./config/programs;
      homeManagerDirContents = builtins.readDir homeManagerProgramsDir;
      homeManagerModuleDirs = builtins.filter (name: homeManagerDirContents.${name} == "directory") (
        builtins.attrNames homeManagerDirContents
      );
      homeManagerModules = map (name: homeManagerProgramsDir + "/${name}") homeManagerModuleDirs;

      # Cross-platform config/programs modules (work on macOS). Excludes the
      # Linux-only desktop-shell ones (hypr, hypridle, matugen, rofi, waybar,
      # wlogout, zen-browser, appearance, cava, user-scripts).
      darwinHomeManagerModules = map (name: homeManagerProgramsDir + "/${name}") [
        "lazygit"
        "mpv"
        "neovim"
        "starship"
        "tmux"
        "zen-browser"
        "opencode"
        "aerospace"
      ];
    in
    {
      nixosConfigurations = {
        zenith = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [
            ./configuration.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.adophilus = import ./users/adophilus/home.nix;
              home-manager.extraSpecialArgs = {
              inherit
                inputs
                end4dots
                wifitui
                gws
                wstui-pkg
                floci-pkg
                sops-nix
                ytd-pkg
                lark-pkg
                open-design-pkg
                pkgs-deprecated
                pkgs-unstable
                ;
                modules = homeManagerModules;
                homeDirectory = "/home/adophilus";
              };
            }
          ];
        };
      };

      # ── macOS (Intel Mac, Sonoma via OCLP) ──────────────────────────────
      # Apply with: darwin-rebuild switch --flake .#nadir
      # NOTE: darwin systems can ONLY be built on macOS. This output declares
      # the config; iterate/build it on the Mac itself.
      darwinConfigurations.nadir = inputs.nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = {
          inherit inputs;
          # nixpkgs-unstable (26.11) dropped x86_64-darwin; use 26.05 (nixpkgs)
          # as the Mac's "unstable" — Intel-darwin is capped at the 26.05 release.
          pkgs-unstable = import nixpkgs {
            system = "x86_64-darwin";
            config.allowUnfree = true;
          };
        };
        modules = [
          ./darwin-configuration.nix
          inputs.nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            # Determinate Nix owns Nix itself — nix-darwin must not fight it.
            nix.enable = false;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.adophilus = import ./users/adophilus/home.nix;
            home-manager.extraSpecialArgs = {
              inherit
                inputs
                end4dots
                wifitui
                gws
                wstui-pkg
                floci-pkg
                lark-pkg
                ;
              # ytd wrapper built for x86_64-darwin (on Linux it comes from the
              # flake-level let, which is x86_64-linux only).
              ytd-pkg = (import nixpkgs {
                system = "x86_64-darwin";
                config.allowUnfree = true;
              }).callPackage ./pkgs/ytd/default.nix { };
              pkgs-deprecated = import nixpkgs-deprecated {
                system = "x86_64-darwin";
                config.allowUnfree = true;
              };
              # nixpkgs-unstable (26.11) dropped x86_64-darwin; use 26.05 (nixpkgs).
              pkgs-unstable = import nixpkgs {
                system = "x86_64-darwin";
                config = {
                  allowUnfree = true;
                  permittedInsecurePackages = [
                    "electron-37.10.3"
                  ];
                };
              };
              # Only cross-platform program modules on macOS.
              modules = darwinHomeManagerModules;
              # macOS home directory (defaults to /home/adophilus on Linux).
              homeDirectory = "/Users/adophilus";
            };
          }
        ];
      };

      homeManagerModules = {
        programs = (
          builtins.foldl' (
            acc: curr: acc // { "${curr}" = homeManagerProgramsDir + "/${curr}"; }
          ) { } homeManagerModuleDirs
        );
        users = {
          adophilus = ./users/adophilus/home.nix;
        };
      };
    };
}
