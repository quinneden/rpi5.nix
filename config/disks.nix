{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          label = "ESP";
          type = "EF00"; # EFI System Partition
          attributes = [ 2 ]; # Legacy BIOS Bootable, for U-Boot to find extlinux config
          size = "1024M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "noatime"
              "noauto"
              "x-systemd.automount"
              "x-systemd.idle-timeout=1min"
              "umask=0077"
            ];
          };
        };

        FIRMWARE = {
          label = "FIRMWARE";
          priority = 1;
          type = "0700"; # Microsoft basic data
          attributes = [ 0 ]; # Required Partition
          size = "1024M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [
              "noatime"
              "noauto"
              "x-systemd.automount"
              "x-systemd.idle-timeout=1min"
            ];
          };
        };

        root = {
          type = "8305";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            extraArgs = [
              "-L"
              "nixos"
            ];
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
