{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware.nix];
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
  environment.systemPackages = with pkgs; [
    kitty
    wofi
    neovim
    git
  ];

  networking.hostName = "qcom-nixos";
  networking.networkmanager = {
    enable = true;
    plugins = [];
  };

  hardware.bluetooth.enable = true;

  programs = {
    #    firefox.enable = true;
    # hyprland = {
    #   enable = true;
    #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #   portalPackage =
    #     inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    # };
  };

  services.openssh.enable = true;

  boot.plymouth.enable = true;

  services.xserver.enable = true;
  services.desktopManager.gnome = {
    enable = true;
  };

  services.displayManager.gdm = {
    enable = true;
    # autoSuspend makes the machine automatically suspend after inactivity.
    # It's possible someone could/try to ssh'd into the machine and obviously
    # have issues because it's inactive.
    # See:
    # * https://github.com/NixOS/nixpkgs/pull/63790
    # * https://gitlab.gnome.org/GNOME/gnome-control-center/issues/22
    autoSuspend = false;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "26.05";
}
