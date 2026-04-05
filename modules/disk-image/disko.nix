{ pkgs, ... }:

{
  disko = {
    devices.disk.main.imageSize = "5G";
    imageBuilder.imageFormat = "raw";
    imageBuilder.kernelPackages = pkgs.linuxPackages_latest;
    memSize = 8192;
  };
}
