let accessKeyId = "chiafan";
    region = "us-west-2";

in {
  network.description = "Chia Plotter";
  network.enableRollback = true;
  
  resources = {
    ec2KeyPairs = {
      chiafan = { inherit accessKeyId region; };
    };

    ec2SecurityGroups = {
      chia-plotter-sg = { resources, ... }: {
        inherit accessKeyId region;
        rules = [
          { fromPort = 22; toPort = 22; sourceIp = "0.0.0.0/0"; }
          { fromPort = 80; toPort = 80; sourceIp = "0.0.0.0/0"; }
          { fromPort = 443; toPort = 443; sourceIp = "0.0.0.0/0"; }
        ];
      };
    };
  };
      
  plotter1 = { resources, config, pkgs, ... }: {
    deployment.targetEnv = "ec2";

    deployment.ec2 = {
      inherit accessKeyId region;

      instanceType = "i3.large";
      # NixOS is quite disk demanding because of nix-store, so giving
      # it a bigger initial disk size would be ideal.
      ebsInitialRootDiskSize = 20;

      keyPair = resources.ec2KeyPairs.chiafan;
      securityGroups = with resources.ec2SecurityGroups; [
        chia-plotter-sg.name
      ];
    };
    
    services.nginx = {
      enable = true;
      virtualHosts."example" = {
        locations."/" = {
          root = "${config.system.build.manual.manualHTML}/share/doc/nixos/";
        };
      };
    };
  };
}
