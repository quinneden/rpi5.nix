{
  networking = {
    firewall.allowedUDPPorts = [ 5353 ];
    firewall.logRefusedConnections = false;

    useNetworkd = true;

    wireless = {
      enable = false;
      iwd.enable = true;
      iwd.settings = {
        Network.EnableIPv6 = true;
        Network.RoutePriorityOffset = 300;
        Settings.AutoConnect = true;
      };
    };
  };

  systemd = {
    network.networks = {
      "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
      "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
    };

    network.wait-online.enable = false;

    services = {
      NetworkManager-wait-online.enable = false;
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
  };
}
