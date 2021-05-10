let accessKeyId = "chiafan";
    region = "us-west-2";

    chiaFarmKey = "8d3e6ed9dc07e3f38fb7321adc3481a95fbdea515f60ff9737c583c5644c6cf83a5e38e9f3e1fc01d43deef0fa1bd0be";
    chiaPoolKey = "ad0dce731a9ef1813dca8498fa37c3abda52ad76795a8327ea883e6aa6ee023f9e06e9a0d5ea1fa3c625261b9da18f12";

    awsCredential = /home/breakds/.aws/credentials;

    # All the are up to you to modify

    makePlotter = requestInstanceType : {resources, config, pkgs, ... }: {
      imports = [
        ../modules/chiabox.nix
        ../modules/chiafan.nix
      ];
      
      deployment.targetEnv = "ec2";

      deployment.ec2 = {
        inherit accessKeyId region;

        instanceType = requestInstanceType;
        # NixOS is quite disk demanding because of nix-store, so giving
        # it a bigger initial disk size would be ideal.
        ebsInitialRootDiskSize = 12;  # GB

        keyPair = resources.ec2KeyPairs.chiafan;
        securityGroups = with resources.ec2SecurityGroups; [
          chia-plotter-sg.name
        ];
      };

      # Add AWS credential for s3 cp/mv purpose.
      deployment.keys.credentials = {
        text = builtins.readFile awsCredential;
        destDir = "/root/.aws";
      };

      fileSystems."/mnt/nvme" = {
        device = "/dev/nvme0n1";
        fsType = "ext4";
        autoFormat = true;
      };

      services.chia-blockchain.plottingDirectory = "/mnt/nvme";

      services.chiafan = {
        farmKey = chiaFarmKey;
        poolKey = chiaPoolKey;
      };

      environment.systemPackages = with pkgs; [
        git emacs awscli2
      ];

      nix = {
        package = pkgs.nixUnstable;
        extraOptions = ''
        experimental-features = nix-command flakes
      '';
      };    
    };

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
          { fromPort = 8444; toPort = 8444; sourceIp = "0.0.0.0/0"; }
          { fromPort = 5000; toPort = 5000; sourceIp = "0.0.0.0/0"; }
        ];
      };
    };
  };

  plotter1 = makePlotter "i3.large";
  plotter2 = makePlotter "i3.large";
  plotter3 = makePlotter "i3.large";
  plotter4 = makePlotter "i3.large";
}
