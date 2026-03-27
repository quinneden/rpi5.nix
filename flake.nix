{
  description = "nix flake for rpi5";

  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi?ref=main";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixos-raspberrypi, ... }@inputs:
    # let
    #   allSystems = [
    #     "aarch64-darwin"
    #     "aarch64-linux"
    #   ];

    #   forSystems =
    #     systems: f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    # in
    {
      # devShells = forSystems allSystems (pkgs: {
      #   default = pkgs.mkShell { nativeBuildInputs = [ pkgs.nix-output-monitor ]; };
      # });

      nixosConfigurations.rpi5 = nixos-raspberrypi.lib.nixosSystemFull {
        specialArgs = {
          inherit inputs;
          inherit nixos-raspberrypi;
        };
        modules = [
          ./modules
          inputs.disko.nixosModules.disko
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
        ];
      };
    };

  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
