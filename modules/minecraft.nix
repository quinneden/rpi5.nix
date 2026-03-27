{ lib, pkgs, ... }:

let
  # Find version url via:
  # curl -sI "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
  geyserPlugin = pkgs.fetchurl {
    url = "https://download.geysermc.org/v2/projects/geyser/versions/2.9.5/builds/1106/downloads/spigot";
    hash = "sha256-zB9bX7WTh8IEaqiIMO18Zxl2K2ZOwLVRSwg5wYyrMvQ=";
  };
  floodgatePlugin = pkgs.fetchurl {
    url = "https://download.geysermc.org/v2/projects/floodgate/versions/2.2.5/builds/131/downloads/spigot";
    hash = "sha256-/4ET56lDGYOF4GEqcuRYAtnJqJeGo8+uhzzCMiMzIWc=";
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

  # Ensure the plugins directory exists and the plugins are symlinked
  # before the server starts.
  systemd.services.minecraft-server.preStart = lib.mkAfter ''
    mkdir -p plugins
    ln -sf ${geyserPlugin} plugins/Geyser-Spigot.jar
    ln -sf ${floodgatePlugin} plugins/Floodgate-Spigot.jar
  '';

  # systemd.services.playit = {
  #   description = "Playit.gg client";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" ];
  #   wants = [ "network-online.target" ];
  #   serviceConfig = {
  #     ExecStart = lib.getExe pkgs.playit-agent;
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #     DynamicUser = true;
  #     StateDirectory = "playit";
  #     WorkingDirectory = "%S/playit";
  #   };
  # };

  environment.systemPackages = [ pkgs.playit-agent ];
}
