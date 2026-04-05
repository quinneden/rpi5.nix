{
  hardware.raspberry-pi.config = {
    # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters
    all = {
      options = {
        # https://www.raspberrypi.com/documentation/computers/config_txt.html#enable_uart
        enable_uart.enable = true;
        enable_uart.value = true;

        # https://www.raspberrypi.com/documentation/computers/config_txt.html#uart_2ndstage
        uart_2ndstage.enable = true;
        uart_2ndstage.value = true;
      };

      # Base DTB parameters
      # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
      base-dt-params = {
        # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
        pciex1.enable = true;
        pciex1.value = "on";

        # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
        pciex1_gen.enable = true;
        pciex1_gen.value = "3";
      };
    };
  };
}
