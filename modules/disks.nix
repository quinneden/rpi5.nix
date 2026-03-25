{
  config,
  lib,
  pkgs,
  ...
}:

let
  espPartition = lib.recursiveUpdate {
    type = "EF00"; # EFI System Partition
    attributes = [ 2 ]; # Legacy BIOS Bootable, for U-Boot to find extlinux config
    size = "1024M";
    content = {
      type = "filesystem";
      format = "vfat";
      mountOptions = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
        "umask=0077"
      ];
    };
  };

  firmwarePartition = lib.recursiveUpdate {
    priority = 1;
    type = "0700"; # Microsoft basic data
    attributes = [ 0 ]; # Required Partition
    size = "1024M";
    content = {
      type = "filesystem";
      format = "vfat";
      mountOptions = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
  };
in

{
  boot.postBootCommands = ''
    if [ ! -f /var/lib/resize-partitions-done ]; then
      set -euo pipefail
      set -x

      rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /)
      bootDevice=$(lsblk -npo PKNAME $rootPart)
      partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

      echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
      ${pkgs.parted}/bin/partprobe
      ${pkgs.btrfs-progs}/bin/btrfs filesystem resize max /

      rm -f /var/lib/resize-partitions-done
    fi
  '';

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # mount early enough in the boot process so no logs will be lost
  fileSystems."/var/log".neededForBoot = true;

  disko = {
    imageBuilder = {
      imageFormat = "raw";
      kernelPackages = pkgs.linuxPackages_latest;
    };
    memSize = 8192;

    devices.disk.main = {
      type = "disk";
      device = "/dev/mmcblk0";
      imageSize = "30G";

      content = {
        type = "gpt";
        partitions = {
          ESP = espPartition {
            label = "ESP";
            content.mountpoint = "/boot";
          };

          FIRMWARE = firmwarePartition {
            label = "FIRMWARE";
            content.mountpoint = "/boot/firmware";
          };

          system = {
            type = "8305"; # Linux ARM64 root
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "--label nixos" ];
              postCreateHook =
                let
                  inherit (config.disko.devices.disk.main.content.partitions.system.content) device subvolumes;

                  makeBlankSnapshot =
                    btrfsMntPoint: subvol:
                    let
                      subvolAbsPath = lib.strings.normalizePath "${btrfsMntPoint}/${subvol.name}";
                      dst = "${subvolAbsPath}-blank";
                      # NOTE: this one-liner has the same functionality (inspired by zfs hook)
                      # btrfs subvolume list -s mnt/rootfs | grep -E ' rootfs-blank$' || btrfs subvolume snapshot -r mnt/rootfs mnt/rootfs-blank
                    in
                    ''
                      if ! btrfs subvolume show "${dst}" > /dev/null 2>&1; then
                        btrfs subvolume snapshot -r "${subvolAbsPath}" "${dst}"
                      fi
                    '';
                  # Mount top-level subvolume (/) with "subvol=/", without it
                  # the default subvolume will be mounted. They're the same in
                  # this case, though. So "subvol=/" isn't really necessary
                in
                ''
                  MNTPOINT=$(mktemp -d)
                  mount ${device} "$MNTPOINT" -o subvol=/
                  trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                  ${makeBlankSnapshot "$MNTPOINT" subvolumes."/rootfs"}
                '';

              subvolumes = {
                "/home" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/home";
                };

                "/log" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/var/log";
                };

                "/nix" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/nix";
                };

                "/rootfs" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/";
                };

                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap."swapfile" = {
                    size = "8G";
                    priority = 3;
                  };
                };
              };
            };
          };

          swap = {
            type = "8200";
            size = "9G";
            content = {
              type = "swap";
              resumeDevice = true;
              priority = 2;
            };
          };
        };
      };
    };
  };

  zramSwap = {
    memoryPercent = 100;
    priority = 4;
  };
}
