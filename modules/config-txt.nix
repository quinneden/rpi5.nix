{
  hardware.raspberry-pi.config.all = {
    # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters
    options = {
      # https://www.raspberrypi.com/documentation/computers/config_txt.html#enable_uart
      enable_uart.enable = true;
      enable_uart.value = true;

      # https://www.raspberrypi.com/documentation/computers/config_txt.html#uart_2ndstage
      uart_2ndstage.enable = true;
      uart_2ndstage.value = true;
    };

    base-dt-params = {
      # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
      pciex1.enable = true;
      pciex1.value = "on";

      # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
      pciex1_gen.enable = true;
      pciex1_gen.value = "3";
    };
  };
}
