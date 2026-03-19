{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./hardware.nix];
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          export CCACHE_SLOPPINESS=random_seed
          export CCACHE_RESHARE=1          
          export CCACHE_REMOTE_STORAGE=file:///mnt/cache/ccache
          
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
  ];

  nix.settings = {
    auto-optimise-store = true;

    extra-sandbox-paths = [config.programs.ccache.cacheDir];
  };

  services.fwupd.enable = true;

  users.users = {
    root.initialPassword = "root";

    tomas = {
      isNormalUser = true;
      initialPassword = "arm";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
      uid = 1000;
    };
  };

  programs.ccache.enable = true;

  fileSystems."/mnt/cache" = {
    device = "192.168.1.102:/volume1/cache";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" 
"x-systemd.idle-timeout=600"
];
};

  environment.systemPackages = with pkgs; [
    ncdu
    gdu
    kitty
    vscode
    direnv
    alejandra
    wget2
    wofi
    neovim
    git
    pv
    gnome-firmware
    htop
    btop
    bottom
    zsh
    usbutils
    lshw
    pciutils
    sbctl
    mission-center
    firmware-manager
    firmware-updater
    nil
    nom
    gparted
    jetbrains-toolbox
  ];

  programs.zsh.enable = true;
  services.pcscd.enable = true;
  services.tailscale.enable = true;

  programs.dconf.profiles.nixos.databases = lib.mkIf false [
    {
      settings = {
        "org/gnome/mutter" = {
          experimental-features = [
            "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
            "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
            "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
            "autoclose-xwayland" # automatically terminates Xwayland if all relevant X11 clients are gone
          ];
        };
      };
    }
  ];

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };

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

  boot.plymouth.enable = true;

  services.xserver = {
    enable = true;

    videoDrivers = [
      "modesetting"
      "fbdev"
      "displaylink"
    ];
  };

  services.desktopManager = {
    # cosmic.enable = true;
    gnome = {
      enable = true;
    };
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
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "tomas"
      ];
    };
  };

  # services.hardware.bolt.enable = true;
  
  services.rpcbind.enable = true;

  boot = {
    growPartition = false;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        netbootxyz.enable = true;
        edk2-uefi-shell.enable = true;
        consoleMode = "max";
      };
    };

    supportedFilesystems = ["nfs" "ntfs"];

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
      options = [
        "fmask=0177"
        "dmask=0077"
      ];
    };
  };

  system.stateVersion = "26.05";
}
