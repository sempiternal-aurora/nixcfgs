{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    aurora-nixpkgs.url = "github:sempiternal-aurora/nixpkgs/stm32cubeide";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    textfox = {
      url = "github:adriankarlen/textfox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deprecated and no longer maintained
    # chaotic-nyx = {
    #   url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.cachyos-kernel.follows = "cachyos-kernel";
      inputs.cachyos-kernel-patches.follows = "cachyos-kernel-patches";
    };

    cachyos-kernel-patches = {
      url = "github:CachyOS/kernel-patches";
      flake = false;
    };

    cachyos-kernel = {
      url = "github:CachyOS/linux-cachyos";
      flake = false;
    };

    nix-doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:Solidsilver/nixos-apple-silicon/feat/vendorfw-support";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nur = {
    #   url = "github:nix-community/nur";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.flake-parts.follows = "flake-parts";
    # };
    #
    # flake-parts = {
    #   url = "github:hercules-ci/flake-parts";
    #   inputs.nixpkgs-lib.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        default = self.nixosConfigurations.coimpiutair;

        myria-live-image = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = {
              adminUser = "nixos";
              configuration = "myria-live-image";
            };
          };
          modules = [
            ./hosts/myria-live-image/configuration.nix
            inputs.home-manager.nixosModules.default
            { nixpkgs.overlays = [ self.outputs.overlays.default ]; }
          ];
        };

        coimpiutair = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = {
              adminUser = "aurora";
              localUser = "myria";
              configuration = "coimpiutair";
            };
          };
          modules = [
            ./hosts/coimpiutair/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.nixos-hardware.nixosModules.framework-13-7040-amd
            { nixpkgs.overlays = [ self.outputs.overlays.default ]; }
          ];
        };

        deideag = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            vars = {
              adminUser = "nyla";
              configuration = "deideag";
            };
          };
          modules = [
            ./hosts/deideag/configuration.nix
            inputs.home-manager.nixosModules.default
            { nixpkgs.overlays = [ self.outputs.overlays.default ]; }
          ];
        };

        macbookair = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
            vars = {
              adminUser = "myria";
              configuration = "macbookair";
            };
          };
          modules = [
            ./hosts/macbookair/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.nixos-apple-silicon.nixosModules.default
            { nixpkgs.overlays = [ self.outputs.overlays.default ]; }
          ];
        };
      };

      overlays.default = import ./pkgs/overlay.nix;

      packages = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.outputs.overlays.default ];
          };
        in
        {
          inherit (pkgs) petro_bot afp;
        }
      );

      darwinConfigurations = {
        default = self.darwinConfigurations.macbookair;
        macbookair = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/macbookair/darwin-configuration.nix
            { nixpkgs.overlays = [ self.outputs.overlays.default ]; }
          ];
          specialArgs = {
            inherit inputs;
            vars = {
              adminUser = "myria";
              configuration = "macbookair";
            };
          };
        };
      };
    };
}
