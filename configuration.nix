
{ inputs, pkgs, lib, ... }:
{
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

  users.users = {
    root.initialPassword = "root";

    user = {
      isNormalUser = true;
      initialPassword = "arm";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  #hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    linux-firmware
    wireless-regdb
    (pkgs.callPackage ./modules/firmware.nix {})
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-path/platform-1bf8000.pci-pci-0006:01:00.0-nvme-1-part6";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };

  environment.systemPackages = with pkgs; [
    kitty
    wofi
    neovim
    git
  ];

  networking.hostName = "qcom-nixos";
  networking.networkmanager = {
    enable = true;
    plugins = [ ];
  };

  hardware.bluetooth.enable = true;

  programs = {
    firefox.enable = true;
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
  };

  services.openssh.enable = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "26.05";
}
