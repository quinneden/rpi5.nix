{ pkgs, inputs, ... }:

{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.paper = {
      enable = true;
      package = pkgs.papermcServers.papermc;

      serverProperties = {
        server-port = 25565;
        # motd = "";
        enable-query = true;
      };
      # whitelist = { };

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Geyser-Spigot = pkgs.fetchurl {
              url = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot";
              hash = "sha256-zB9bX7WTh8IEaqiIMO18Zxl2K2ZOwLVRSwg5wYyrMvQ=";
            };
          }
        );
      };
    };
  };
}
