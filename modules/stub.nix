{ config, ... }:

{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    initialHashedPassword = "";
  };

  users.users.root.initialHashedPassword = "";

  security.polkit.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.getty.autologinUser = "nixos";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  nix.settings = {
    extra-experimental-features = "nix-command flakes";
    trusted-users = [ "@wheel" ];
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  system.stateVersion = config.system.nixos.release;
}
