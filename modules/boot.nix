{ pkgs, ... }:

{
  boot = {
    postBootCommands = ''
      marker=/var/lib/.grow-rootpart-done

      if [[ ! -f $marker ]]; then
        set -euo pipefail
        set -x

        rootPart=$(${pkgs.util-linux}/bin/findmnt -nvo SOURCE /)
        bootDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(lsblk -npo MIN $rootPart)

        echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.btrfs-progs}/bin/btrfs filesystem resize max /

        touch $marker
        chattr +i $marker
      fi
    '';

    kernelPackages = pkgs.linuxAndFirmware.latest.linuxPackages_rpi5;
    loader.raspberryPi.bootloader = "kernel";
    loader.raspberryPi.firmwarePackage = pkgs.linuxAndFirmware.latest.raspberrypifw;
    tmp.useTmpfs = true;
  };
}
