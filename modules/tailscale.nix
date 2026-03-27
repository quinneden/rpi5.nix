{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
  };

  environment.systemPackages = [ pkgs.tailscale ];
}
