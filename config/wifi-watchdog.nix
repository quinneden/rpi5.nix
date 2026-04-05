{ pkgs, ... }:

{
  # Watchdog that detects the brcmfmac "connected but dead" state (L2 association
  # intact, L3 data path silently broken after SAE re-auth failure) and recovers
  # by restarting iwd, which tears down and resets the driver state.
  systemd.services.wifi-watchdog = {
    description = "WiFi connectivity watchdog for brcmfmac SAE bug";
    after = [
      "network-online.target"
      "iwd.service"
    ];
    requires = [ "iwd.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        let
          script = pkgs.writeShellApplication {
            name = "wifi-watchdog";
            runtimeInputs = with pkgs; [
              gawk
              iputils
              iwd
              systemd
            ];
            text = ''
              IFACE="wlan0"
              PING_TARGET="1.1.1.1"

              state=$(iwctl station "$IFACE" show 2>/dev/null \
                | awk '/State/ {print $NF}')

              if [ "$state" != "connected" ]; then
                exit 0
              fi

              if ping -c 2 -W 3 -I "$IFACE" "$PING_TARGET" >/dev/null 2>&1; then
                exit 0
              fi

              echo "wifi-watchdog: ping failed while $IFACE reports connected — restarting iwd"
              systemctl restart iwd.service
              sleep 10
              networkctl reconfigure "$IFACE" 2>/dev/null || true
            '';
          };
        in
        "${script}/bin/wifi-watchdog";
    };
  };

  systemd.timers.wifi-watchdog = {
    description = "WiFi watchdog timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "2min";
      Unit = "wifi-watchdog.service";
    };
  };
}
