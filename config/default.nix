{ config, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./config-txt.nix
    ./disks.nix
    ./minecraft
    ./networking.nix
    ./nix.nix
    ./ssh.nix
    ./tailscale.nix
    ./wifi-watchdog.nix
  ];

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz";
    colors = [
      "000000"
      "06989A"
      "3465A4"
      "34E2E2"
      "4E9A06"
      "555753"
      "739FCF"
      "75507B"
      "8AE234"
      "AD7FA8"
      "C4A000"
      "CC0000"
      "D3D7CF"
      "EEEEEC"
      "EF2929"
      "FCE94F"
    ];
  };

  environment.systemPackages = with pkgs; [
    bat
    eza
    fd
    gh
    git
    gptfdisk
    jq
    micro
    raspberrypi-eeprom
    ripgrep
    wget
  ];

  security = {
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  system = {
    nixos.tags = [
      "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
      config.boot.kernelPackages.kernel.version
      config.boot.loader.raspberry-pi.bootloader
    ];
    stateVersion = config.system.nixos.release;
  };

  time.timeZone = "America/Los_Angeles";

  users.users.qeden = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
