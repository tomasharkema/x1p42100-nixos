{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  readmbn = pkgs.callPackage ./packages/readmbn.nix {};
  firm = pkgs.callPackage ./packages/firmware.nix {};
  clearviewhwy = pkgs.callPackage ./packages/clearviewhwy.nix {};
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
  imports = [
    ./hardware.nix
    ./ccache.nix
  ];
  nixpkgs.config.allowUnfree = true;

  nix = {
    channel.enable = true;
    optimise.automatic = true;

    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;
      cores = 6;
      extra-sandbox-paths = [
        config.programs.ccache.cacheDir
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
    # root.initialPassword = "root";

    tomas = {
      isNormalUser = true;
      # initialPassword = "arm";
      extraGroups = [
        "wheel"
        "dialout"
        "networkmanager"
        "docker"
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

  programs.geary.enable = true;
  environment.shells = [pkgs.zsh];
  programs.nh.enable = true;
  programs._1password = {
    enable = true;
    package = pkgs._1password-cli;
  };
  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-8.12.21.arm64.tar.gz";
        hash = "sha256-WPFUqKKfdadzF7BtR9gUm0SlYq4ZN36eICfGsPxirH0=";
      };
    });
    polkitPolicyOwners = ["tomas"];
  };
  virtualisation.docker.enable = true;

  # services.cachix-watch-store = {
  #   enable = true;
  #   cacheName = "qcom-x1p42100";
  # };

  nixpkgs.config.segger-jlink.acceptLicense = true;
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    alejandra
    apple-cursor
    attic-client
    autojump
    bottles
    clearviewhwy
    bottom
    brave
    btop
    btrfs-assistant
    cachix
    calc
    caligula
    chromium
    contact
    darktable
    devcontainer
    devenv
    direnv
    distrobox
    # firefoxpwa
    firmware-manager
    firmware-updater
    flatpak-builder
    fractal
    fzf
    gcc
    gdu
    gh
    ghostty
    git
    gnome-firmware
    gnome-tweaks
    gnumake
    gparted-full
    helix
    htop
    hw-probe
    kitty
    lazygit
    lm_sensors
    lshw
    minicom
    mission-center
    ncdu
    neovim
    nil
    nix-index
    nix-init
    nix-search
    nix-search-cli
    nix-search-tv
    nixd
    nom
    nrfconnect
    pciutils
    pv
    pwvucontrol
    readmbn
    sshfs
    refine
    resilio-sync
    ripgrep
    rsync
    squashfs-tools-ng
    squashfsTools
    starship
    systemctl-tui
    telegram-desktop
    television
    tio
    tv
    usbutils
    uxplay
    vscode
    waypipe
    wget2
    wike
    wikiman
    wofi
    yazi
    zellij
    zsh
  ];

  services.keyd = {
    enable = true;
    keyboards."default".settings = {
      main = {
        "leftshift+leftmeta" = "layer(control)";
      };
    };
  };

  services.gvfs.enable = true;
  hardware.wooting.enable = true;
  hardware.sensor.iio.enable = true;
  programs.gphoto2.enable = true;
  programs.zsh.enable = true;
  services.pcscd.enable = true;
  services.tailscale = {
    enable = true;
  };

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
      clearviewhwy
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

  services.kmscon = {
    enable = true;

    config.font-name = "AdwaitaMono-Regular";
  };

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    jack.enable = true;

    wireplumber = {
      enable = true;
    };
  };
  services.cachefilesd.enable = true;
  services.usbmuxd.enable = true;
  networking.modemmanager.enable = false;

  # # set up enivronment so that UCM configs are used as well
  # environment.variables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-firm}/share/alsa/ucm2";
  # systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 =
  #   config.environment.variables.ALSA_CONFIG_UCM2;
  # systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
  #   config.environment.variables.ALSA_CONFIG_UCM2;
  # systemd.services.pipewire.environment.ALSA_CONFIG_UCM2 =
  #   config.environment.variables.ALSA_CONFIG_UCM2;
  # systemd.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
  #   config.environment.variables.ALSA_CONFIG_UCM2;

  services.kbfs = {
    enable = true;
    # mountPoint = "/keybase";
    # enableRedirector = true;
    extraFlags = [
      "-label Keybase"
      # "-mount-type normal"
      # "-debug"
    ];
  };

  systemd.user.services.kbfs = {
    environment = {
      PATH = lib.mkForce "/run/wrappers/bin";
      KEYBASE_SYSTEMD = "1";
    };
    serviceConfig = {
      ExecStartPre = lib.mkForce [
        "${pkgs.coreutils}/bin/mkdir -p \"${config.services.kbfs.mountPoint}\""
      ];

      PrivateTmp = lib.mkForce null;
    };
  };

  # security.wrappers."keybase-redirector" = {
  #   owner = "root";
  #   group = "root";
  # };

  # systemd.network.units."80-iwd.link".enable = lib.mkForce false;

  networking = {
    hostName = "qcom-nixos";

    # wireless = {
    #   enable = false; # true; # false;
    #   iwd = {
    #     enable = true;
    #     settings = {
    #       General.ControlPortOverNL80211 = false;
    #       Settings = {
    #         AutoConnect = true;
    #         # AlwaysRandomizeAddress = true;
    #       };
    #       Network = {
    #         EnableIPv6 = true;
    #         RoutePriorityOffset = 300;
    #       };
    #       # DriverQuirks.DefaultInterface = "wlan0";
    #     };
    #   };
    # };

    networkmanager = {
      enable = true;

      wifi = {
        # powersave = true;
        # backend = "iwd";
      };
    };
  };

  hardware.bluetooth.enable = true;

  programs = {
    firefox = {
      enable = true;
      # package = pkgs.firefox;
    };
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

    autoSuspend = false;
  };

  services.hardware.bolt.enable = true;
  hardware.flipperzero.enable = true;
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
    supportedFilesystems = {
      nfs = true;
      ntfs = true;
      btrfs = true;
    };
    crashDump.enable = true;

    # kernelModules = ["kvm"];
    kernelParams = [
      #"drm.debug=0x100"
    ];

    blacklistedKernelModules = [
      "qcom-iris"
      #   "soundwire-qcom"
      #   "snd-mixer-oss"
      #   "snd-pcm-oss"
    ];

    initrd = {
      # availableKernelModules = ["kvm"];
      # compressor = "zstd";
      # compressorArgs = ["-19"];
    };
  };

  services.fstrim.enable = true;

  time = {
    hardwareClockInLocalTime = true;
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
        "compress=zstd"
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
    # "/mnt/cache" = {
    #   device = "192.168.1.102:/volume1/cache";
    #   fsType = "nfs";
    #   options = [
    #     "x-systemd.automount"
    #     "noauto"
    #     "x-systemd.idle-timeout=600"
    #   ];
    # };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/disk-swap";
      # size = 16 * 1024;
      options = ["discard"];
    }
  ];
  boot.resumeDevice = "/dev/disk/by-partlabel/disk-swap";
  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
