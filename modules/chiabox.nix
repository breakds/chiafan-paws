{ config, pkgs, lib, ... }:

let cfg = config.services.chia-blockchain;

    containerName = "chiabox";

    chiafunc = pkgs.writeShellScriptBin "chiafunc" ''
      state=$(docker inspect -f "{{.State.Status}}" ${containerName})
      if [ "$state" != "running" ]; then
        echo "Please make sure that the chia docker container is running."
        exit -1
      fi
      docker exec -it ${containerName} venv/bin/chia $@
    '';

in {
  options.services.chia-blockchain = with lib; {
    plottingDirectory = mkOption {
      type = lib.types.str;
      description = ''
        Specify the path to the directory that serves as temporary directory while plotting.
        
        This will be mount to /plotting inside the docker container.

        Note that the faster the disk (nvme) the better performance you will have for plotting.
      '';
      default = "";
      example = "/opt/chia/plots";
    };
  };
  
  config = {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers."${containerName}" = {
      image = "ghcr.io/chia-network/chia:latest";
      volumes = (lib.optionals (cfg.plottingDirectory != "") [ "${cfg.plottingDirectory}:/plotting" ]);

      environment = {
        "keys" = "";  # Skip generating keys on startup
        "plots_dir" = "/plots";
      };
    };

    environment.systemPackages = [ chiafunc ];

    networking.firewall.allowedTCPPorts = [ 8444 ];
  };
}
