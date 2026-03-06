{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware.nix];
  nixpkgs.config.allowUnfree = true;
  users.users = {
    root.initialPassword = "root";

    nixos = {
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

  networking = {
    hostName = "qcom-nixos";

    wireless = {
      enable = false; # true;
      iwd = {
        enable = true;
        settings = {
          Settings = {
            AutoConnect = true;
            AlwaysRandomizeAddress = true;
          };
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          DriverQuirks.DefaultInterface = "wlan0";
        };
      };
    };

    networkmanager = {
      enable = true;

      wifi = {
        backend = "iwd";
      };
    };
  };

  hardware.bluetooth.enable = true;

  programs = {
    firefox.enable = true;
    # hyprland = {
    #   enable = true;
    #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #   portalPackage =
    #     inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    # };
  };

  services.openssh.enable = true;

  # boot.plymouth.enable = true;

  services.xserver.enable = true;
  services.desktopManager.gnome = {
    enable = true;
  };
  services.flatpak = {
    enable = true;

    # remotes = [
    #   {
    #     name = "flathub";
    #     location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    #   }
    # ];
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

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  boot = {
    growPartition = false;
    loader = {
      systemd-boot.enable = true;
    };
  
initrd = {
};
};

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  system.stateVersion = "26.05";
}
