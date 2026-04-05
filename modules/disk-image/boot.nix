{ pkgs, ... }:

{
  boot.postBootCommands =
    let
      marker = "/var/lib/.grow-rootpart-done";
    in
    ''
      if [[ ! -f ${marker} ]]; then
        set -xeuo pipefail

        rootPart=$(${pkgs.util-linux}/bin/findmnt -no SOURCE /)
        bootDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(lsblk -npo MIN $rootPart)

        echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        touch ${marker}
        chattr +i ${marker}
      fi
    '';
}
