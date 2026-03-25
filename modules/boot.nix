{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxAndFirmware.latest.linuxPackages_rpi5;
    loader.raspberryPi.bootloader = "kernel";
    loader.raspberryPi.firmwarePackage = pkgs.linuxAndFirmware.latest.raspberrypifw;
    tmp.useTmpfs = true;
  };
}
