{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.playit-agent;

  playit-attach = pkgs.writeShellScriptBin "playit-attach" ''
    shopt -s nullglob

    if [[ $EUID != 0 ]]; then
      echo "You have to be root (or use sudo) to attach to the console." >&2
      exit 1
    fi

    tmuxSocket="/run/playit-agent/tmux"

    if [[ ! -e $tmuxSocket ]]; then
      echo "error: service not started (socket not found at $tmuxSocket)." >&2
      exit 1
    fi

    exec runuser -u ${cfg.user} -- ${lib.getExe pkgs.tmux} -S "$tmuxSocket" attach-session
  '';
in

{
  options.services.playit-agent = {
    enable = lib.mkEnableOption "playit.gg agent service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.playit-agent;
      description = "The playit-agent package to use.";
    };

    secretPath = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.dataDir}/playit.toml";
      description = "Path to the secret file containing the agent's unique key.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/playit_agent";
      description = "Working directory for the playit-agent service.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "playit_agent";
      description = "User account under which playit-agent runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "playit_agent";
      description = "Group account under which playit-agent runs.";
    };

    useTmux = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Run playit-agent inside a detached tmux session to allow attaching to its console.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "start" ];
      description = "Extra arguments and subcommand to pass to the playit-agent.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      description = "Playit.gg agent service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = { };

    systemd.services.playit-agent = {
      description = "Playit.gg agent service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = if cfg.useTmux then "forking" else "simple";

        ExecStart =
          let
            baseCmd = "${lib.getExe cfg.package} --secret_path ${cfg.secretPath} ${lib.escapeShellArgs cfg.extraArgs}";
          in
          if cfg.useTmux then
            ''
              ${lib.getExe pkgs.tmux} \
                -S /run/playit-agent/tmux \
                set -g default-shell ${lib.getExe pkgs.bashInteractive} ";" \
                new-session -d "${baseCmd}"
            ''
          else
            baseCmd;

        ExecStop = lib.mkIf cfg.useTmux "${lib.getExe pkgs.tmux} -S /run/playit-agent/tmux kill-server";

        KillMode = "mixed";
        Restart = "always";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
        RuntimeDirectory = "playit-agent";

        # Security hardening
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [ cfg.dataDir ];
        RestrictSUIDSGID = true;
      };
    };

    environment.systemPackages = [ cfg.package ] ++ lib.optional cfg.useTmux playit-attach;
  };
}
