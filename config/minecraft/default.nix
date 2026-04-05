{ lib, pkgs, ... }:

let
  # Find version url via:
  # curl -sI "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
  geyser = pkgs.fetchurl {
    name = "Geyser-Spigot.jar";
    url = "https://download.geysermc.org/v2/projects/geyser/versions/2.9.5/builds/1106/downloads/spigot";
    hash = "sha256-zB9bX7WTh8IEaqiIMO18Zxl2K2ZOwLVRSwg5wYyrMvQ=";
  };
  floodgate = pkgs.fetchurl {
    name = "Floodgate-Spigot.jar";
    url = "https://download.geysermc.org/v2/projects/floodgate/versions/2.2.5/builds/131/downloads/spigot";
    hash = "sha256-/4ET56lDGYOF4GEqcuRYAtnJqJeGo8+uhzzCMiMzIWc=";
  };
in

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = pkgs.papermcServers.papermc-1_21_11;
    declarative = true;

    serverProperties = {
      allow-flight = false;
      debug = false;
      difficulty = "peaceful";
      gamemode = "survival";
      max-players = 20;
      motd = "Quinn's MC server";
      op-permission-level = 4;
      server-port = 25565;
      white-list = false;
    };
  };

  networking.firewall.allowedUDPPorts = [ 19132 ];

  systemd.services.minecraft-server.preStart = lib.mkAfter ''
    mkdir -p plugins/Geyser-Spigot config

    ln -sf ${./config/paper-global.yml} config/paper-global.yml
    ln -sf ${./config/paper-world-defaults.yml} config/paper-world-defaults.yml
    ln -sf ${floodgate} plugins/Floodgate-Spigot.jar
    ln -sf ${geyser} plugins/Geyser-Spigot.jar
    ln -sf ${./config/geyser-config.yml} plugins/Geyser-Spigot/config.yml
  '';

  services.playit-agent = {
    enable = true;
    secretPath = "/etc/playit_gg/playit.toml";
    useTmux = true;
  };
}
