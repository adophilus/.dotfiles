{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };

    # hypr-dynamic-cursors = {
    #   url = "github:VirtCode/hypr-dynamic-cursors";
    #   inputs.hyprland.follows =
    #     "hyprland"; # to make sure that the plugin is built for the correct version of hyprland
    # };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      end4dots,
      wifitui,
      gws,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      # Build wstui from stable nixpkgs (has the deps we need)
      wstui-pkg = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/wstui/default.nix { };
      floci-pkg = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/floci/default.nix { };
    in
    {
      nixosConfigurations = {
        zenith = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
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
                  ;
                pkgs-unstable = import nixpkgs-unstable {
                  inherit system;
                  config = {
                    allowUnfree = true;
                    permittedInsecurePackages = [
                      "electron-37.10.3"
                    ];
                  };
                };
              };
            }
          ];
        };
      };
    };
}
