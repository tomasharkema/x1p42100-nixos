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
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 2;
      };
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
