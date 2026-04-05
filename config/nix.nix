{ lib, self, ... }:

{
  nix.settings = {
    accept-flake-config = true;
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];

    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];

    trusted-users = [ "@wheel" ];
    warn-dirty = false;
  };

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    overlays = lib.mkAfter [
      self.overlays.default
      (final: prev: {
        inherit (final.linuxAndFirmware.latest) raspberrypifw raspberrypiWirelessFirmware;
      })
    ];
  };
}
