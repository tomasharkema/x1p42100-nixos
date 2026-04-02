{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  slbounce = pkgs.callPackage ./packages/slbounce.nix {};
  qebspil = pkgs.callPackage ./packages/qebspil.nix {};
  readmbn = pkgs.callPackage ./packages/readmbn.nix {};
  firm = pkgs.callPackage ./packages/firmware.nix {};
  alsa-ucm-conf-firm = pkgs.symlinkJoin {
    inherit
      (pkgs.alsa-ucm-conf)
      pname
      version
      src
      passthru
      meta
      ;
    paths = [
      pkgs.alsa-ucm-conf
      pkgs.alsa-ucm-conf-asahi
      firm
    ];
  };
in {
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
          export CCACHE_MAXSIZE=20GB
          export CCACHE_RESHARE=true
          export CCACHE_REMOTE_STORAGE=file:/mnt/cache/ccache

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

  nix = {
    channel.enable = true;
    optimise.automatic = true;

    settings = {
      auto-optimise-store = true;

      extra-sandbox-paths = [
        config.programs.ccache.cacheDir
        "/var/log/ccache"
        "/mnt/cache/ccache"
      ];

      use-cgroups = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
      ];
      trusted-users = [
        "root"
        "tomas"
      ];
    };
  };

  services.fwupd.enable = true;

  users.users = {
    root.initialPassword = "root";

    tomas = {
      isNormalUser = true;
      initialPassword = "arm";
      extraGroups = [
        "wheel"

        "dialout"
        "networkmanager"
      ];
      shell = pkgs.zsh;
      uid = 1000;
    };
  };

  # programs.ssh = {
  #   extraConfig = ''
  #     Host *
  #      IdentityAgent ~/.1password/agent.sock
  #   '';
  # };

  programs.direnv.enable = true;

  programs.ccache.enable = true;
  programs.geary.enable = true;
  environment.shells = [pkgs.zsh];
  programs.nh.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = ["tomas"];
  };

  environment.systemPackages = with pkgs; [
    bottles
    minicom
    impala
    pwvucontrol
    alejandra
    apple-cursor
    bottom
    btop
    btrfs-assistant
    chromium
    devenv
    direnv
    firmware-manager
    firmware-updater
    fzf
    gdu
    ghostty
    git
    gnome-firmware
    gnome-tweaks
    gparted
    helix
    htop
    hw-probe
    kitty
    lazygit
    lm_sensors
    lshw
    mission-center
    ncdu
    neovim
    nil
    nixd
    nom
    pciutils
    pv
    readmbn
    refine
    ripgrep
    caligula
    rsync
    sbctl
    squashfs-tools-ng
    squashfsTools
    systemctl-tui
    telegram-desktop
    television
    nix-init
    tio
    usbutils
    vscode
    wget2
    wikiman
    wofi
    yazi
    zed-editor
    zsh
  ];
  hardware.sensor.iio.enable = true;
  programs.zsh.enable = true;
  services.pcscd.enable = true;
  services.tailscale = {
    enable = true;
  };
  virtualisation.waydroid.enable = true;
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf

      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.adwaita-mono
      adwaita-fonts
    ];
  };
  programs.dconf.profiles.tomas.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "purple";
        };

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
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;

    wireplumber = {
      enable = true;
    };
  };

  # # set up enivronment so that UCM configs are used as well
  environment.variables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-firm}/share/alsa/ucm2";
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;

  # services.udev.extraRules = ''
  #   SUBSYSTEM=="net", ACTION=="add", \
  #     ATTRS{subsystem_device}=="0x1414", \
  #     ATTRS{subsystem_vendor}=="0x00ab", \
  #     ATTRS{vendor}=="0x17cb", \
  #     PROGRAM="${pkgs.iproute2}/bin/ip link set %k address 8c:1d:55:0d:50:54"
  # '';

  # systemd.network.units."80-iwd.link".enable = lib.mkForce false;

  networking = {
    hostName = "qcom-nixos";

    wireless = {
      enable = false; # true; # false;
      iwd = {
        enable = true;
        settings = {
          #General.ControlPortOverNL80211 = false;
          Settings = {
            AutoConnect = true;
            # AlwaysRandomizeAddress = true;
          };
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          # DriverQuirks.DefaultInterface = "wlan0";
        };
      };
    };

    networkmanager = {
      enable = true;

      wifi = {
        powersave = true;
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

  services.hardware.bolt.enable = true;
  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      workstation = true;
      userServices = true;
    };
  };
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
        extraFiles = {
          "EFI/systemd/drivers/slbounceaa64.efi" = "${slbounce}/slbounce.efi";
          "EFI/systemd/drivers/qebspilaa64.efi" = "${qebspil}/qebspilaa64.efi";
        };
      };
    };

    blacklistedKernelModules = [
      "qcom-iris"
      #"soundwire-qcom"
      "snd-mixer-oss"
      "snd-pcm-oss"
    ];

    supportedFilesystems = {
      nfs = true;
      ntfs = true;
      btrfs = true;
    };
    crashDump.enable = true;
    kernelModules = ["kvm"];
    initrd = {
      availableKernelModules = ["kvm"];
      compressor = "zstd";
      compressorArgs = ["-19"];
    };
  };

  services.fstrim.enable = true;

  time = {
    hardwareClockInLocalTime = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/48870f93-19d4-499b-baf4-9a740791cdb2";
      fsType = "btrfs";
      options = [
        "subvol=rootfs"
        #"compress=zstd"
        "noatime"
      ];
      neededForBoot = true;
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/48870f93-19d4-499b-baf4-9a740791cdb2";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "noatime"
      ];
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = [
        "fmask=0177"
        "dmask=0077"
      ];
    };
    "/mnt/cache" = {
      device = "192.168.1.102:/volume1/cache";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=600"
      ];
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 16 * 1024;
      options = ["discard"];
    }
  ];

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
