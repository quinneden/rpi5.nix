{
  config,
  lib,
  pkgs,
  ...
}:

let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKP9m53womx+hnQFRljUzv/PrCuFEYKgmPrmdzYSMQcX";
in

{
  imports = [
    ./boot.nix
    ./config-txt.nix
    ./disks.nix
    ./networking.nix
    ./nice-looking-console.nix
    ./stub.nix
  ];

  time.timeZone = "America/Los_Angeles";
  networking.hostName = "rpi5";

  services.udev.extraRules = ''
    # Ignore partitions with "Required Partition" GPT partition attribute
    # On our RPis this is firmware (/boot/firmware) partition
    ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
      ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
      ENV{UDISKS_IGNORE}="1"
  '';

  environment.systemPackages = with pkgs; [
    bat
    eza
    fd
    gh
    git
    gptfdisk
    jq
    micro
    ripgrep
    wget
  ];

  users.users.nixos.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];

  system.nixos.tags = [
    "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
    config.boot.kernelPackages.kernel.version
    config.boot.loader.raspberry-pi.bootloader
  ];

  nixpkgs.overlays = lib.mkAfter [
    (final: prev: {
      inherit (final.linuxAndFirmware.latest) raspberrypifw raspberrypiWirelessFirmware;
    })
  ];
}
