{ lib, pkgs, ... }:

let
  # Find version url via:
  # curl -sI "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
  geyserPlugin = pkgs.fetchurl {
    url = "https://download.geysermc.org/v2/projects/geyser/versions/2.9.5/builds/1106/downloads/spigot";
    hash = "sha256-zB9bX7WTh8IEaqiIMO18Zxl2K2ZOwLVRSwg5wYyrMvQ=";
  };
in
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true; # Opens the default TCP port (25565) for Java Edition

    # Use PaperMC as the server software
    package = pkgs.papermc;

    # Make server.properties declarative
    declarative = true;

    serverProperties = {
      server-port = 25565;
      motd = "Quinn's MC server via PaperMC + Geyser";
    };
  };

  # Open the default UDP port (19132) for Bedrock Edition (Geyser)
  networking.firewall.allowedUDPPorts = [ 19132 ];

  # Ensure the plugins directory exists and the Geyser plugin is copied
  # before the server starts.
  systemd.services.minecraft-server.preStart = lib.mkAfter ''
    mkdir -p plugins
    ln -sf ${geyserPlugin} plugins/Geyser-Spigot.jar
  '';
}
