{
  description = "nix flake for rpi5";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      nixos-raspberrypi,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
      ];

      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            }
          )
        );
    in
    {
      apps = eachSystem (pkgs: {
        deploy = {
          type = "app";
          program = pkgs.lib.getExe (pkgs.callPackage ./apps/deploy { inherit self; });
        };
      });

      nixosConfigurations.rpi5 = nixos-raspberrypi.lib.nixosSystemFull {
        inherit nixpkgs;
        specialArgs = { inherit inputs nixos-raspberrypi self; };
        modules = [
          ./config
          inputs.disko.nixosModules.disko
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
          self.nixosModules.playit-agent
        ];
      };

      nixosModules = import ./modules;

      overlays.default =
        final: prev:
        (nixpkgs.lib.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = ./pkgs;
        });

      packages = eachSystem (pkgs: {
        inherit (pkgs) playit-agent;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.diskImage;
        diskImage =
          let
            extended = self.nixosConfigurations.rpi5.extendModules {
              modules = [ self.nixosModules.disk-image ];
            };
          in
          extended.config.system.build.diskoImages;
      });
    };

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
