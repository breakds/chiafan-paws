{ config, lib, pkgs, ... }:

let cfg = config.services.chiafan;

    chiafan = pkgs.callPackage ../pkgs/chiafan {};

in {
  options.services.chiafan = with lib; {
    farmKey = mkOption {
      type = types.str;
      description = ''
        The farmer key of the plots that is being plotted.

        This can be obtained by running `chia keys show`
      '';
      default = "";
      example = "8d3e6ed9dc07e3f38fb7321adc3481a95fbdea515f60ff9737c583c5644c6cf83a5e38e9f3e1fc01d43deef0fa1bd0be";
    };

    poolKey = mkOption {
      type = types.str;
      description = ''
        The pool key of the plots that is being plotted.

        This can be obtained by running `chia keys show`
      '';
      default = "";
      example = "ad0dce731a9ef1813dca8498fa37c3abda52ad76795a8327ea883e6aa6ee023f9e06e9a0d5ea1fa3c625261b9da18f12";
    };
  };

  config = {
    systemd.services.chiafan = {
      description = "The service that plots chia";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        utillinux
        docker
        awscli2
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${chiafan}/bin/chiafan \
            --farm_key ${cfg.farmKey} \
            --pool_key ${cfg.poolKey}
        '';
        Restart = "no";
      };
    };

    networking.firewall.allowedTCPPorts = [ 5000 ];
  };
}
