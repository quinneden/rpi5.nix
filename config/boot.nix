{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxAndFirmware.latest.linuxPackages_rpi5;
    loader.raspberry-pi.bootloader = "kernel";
    loader.raspberry-pi.firmwarePackage = pkgs.linuxAndFirmware.latest.raspberrypifw;
    tmp.useTmpfs = true;

    # brcmfmac (Broadcom CYW43455) on RPi5 has a bug where WPA3 SAE external
    # authentication fails after a while: the firmware fires EXT_AUTH_REQ (event
    # 187) to ask iwd to perform a fresh SAE exchange, but iwd's handling of this
    # brcmfmac-specific external-auth path is broken on kernel >= 6.6. The
    # firmware then silently kills the data path while the 802.11 association
    # stays "connected", producing the limbo state where ip/iwctl report connected
    # but nothing routes. Disabling firmware supplicant (FWSUP, bit 13), SAE
    # offload (bit 19), and DUMP_OBSS (bit 21) removes the broken external-auth
    # path entirely; on WPA2/WPA3 mixed networks the driver falls back to WPA2
    # cleanly. roamoff=1 prevents the firmware's BSS re-evaluation from ever
    # reaching the EXT_AUTH_REQ trigger in the first place.
    # See: RPi-Distro/firmware-nonfree (April 2025), NixOS issue #425395.
    extraModprobeConfig = ''
      options brcmfmac roamoff=1 feature_disable=0x282000
    '';
  };

  services.udev.extraRules = ''
    # Ignore partitions with "Required Partition" GPT partition attribute
    # On our RPis this is firmware (/boot/firmware) partition
    ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
      ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
      ENV{UDISKS_IGNORE}="1"
  '';
}
