{
  networking = {
    hostName = "rpi5";
    firewall.allowedUDPPorts = [ 5353 ];
    firewall.logRefusedConnections = false;

    useDHCP = false;
    useNetworkd = true;

    interfaces.wlan0.useDHCP = true;

    wireless = {
      enable = false;
      iwd.enable = true;
      iwd.settings = {
        # Prevents iwd from issuing ANQP (Hotspot 2.0) query frames during
        # scan, which brcmfmac handles poorly and can contribute to driver
        # state confusion.
        General.DisableANQP = true;
        DriverQuirks.PowerSaveDisable = "wlan";
      };
    };
  };

  systemd = {
    services = {
      NetworkManager-wait-online.enable = false;
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
  };
}
