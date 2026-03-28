{
  inputs,
  pkgs,
  lib,
  ...
}: let
  firm = pkgs.callPackage ./packages/firmware.nix {};
in {
  # Ucomment the lines below for use in a flake config

  # imports = [
  #   inputs.x1p42100-nixos.nixosModules.x1p
  # ];

  boot = {
    # consoleLogLevel = 9;
    kernelModules = [
      "kvm"
    ];
    kernelParams = [
      # "debug"
      # "nohibernate"
      # "udev.log_level=7"
      # "rd.systemd.debug_shell"
      # "console=tty0"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # enable = lib.mkForce false; # true;
        # configurationLimit = 2;
      };
      # refind.enable = true;
      # grub = {
      #   enable = lib.mkForce true;
      #   device = "/dev/disk/by-label/ESP";
      # };
    };
    initrd = {
      enable = true;
      systemd.enable = true;
    };
  };

  environment = {
     systemPackages = [firm];
    pathsToLink = ["/share/alsa"];
  };

  hardware = {
    enableRedistributableFirmware = lib.mkForce false; # true;;
    firmware = with pkgs; [
      linux-firmware
      wireless-regdb
      firm
    ];
  };
}
