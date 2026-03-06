{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Ucomment the lines below for use in a flake config

  # imports = [
  #   inputs.x1p42100-nixos.nixosModules.x1p
  # ];

  boot = {
    # consoleLogLevel = 9;
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
        configurationLimit = 2;
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

  hardware = {
    enableRedistributableFirmware = true;
    firmware = with pkgs; [
      linux-firmware
      wireless-regdb
      (pkgs.callPackage ./modules/firmware.nix {})
    ];
  };
}
