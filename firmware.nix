{ pkgs, ... }:

let
  # 1. Fetch Harrison's repository directly out-of-band via GitHub API
  surface-repo = pkgs.fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "main"; 
    
    # NOTE: This is a placeholder hash. Nix will intentionally fail on the first run 
    # and print the correct sha256 hash. Copy that hash and paste it here!
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # 2. Build the firmware derivation out of the fetched source
  surface-firmware = pkgs.stdenvNoCC.mkDerivation {
    name = "snapdragon-surface-firmware";
    src = surface-repo; 

    dontBuild = true;

    installPhase = ''
      # Generate the strict destination directory tree required by the SoC
      mkdir -p "$out/lib/firmware/qcom/x1p42100/Microsoft/Surface12"
      
      # Handle repo variants: copy from 'firmware/' folder if it exists, otherwise copy root contents
      cp -r lib/firmware/* "$out/lib/firmware/"
    '';
  };
in
{
  # Allow unfree drivers (needed for proprietary Qualcomm .mbn firmware blobs)
  nixpkgs.config.allowUnfree = true;

  # Expose the derivation contents to the running Stage 2 OS filesystem
  hardware.firmware = [ 
    surface-firmware 
  ];

  # Pre-load storage and graphics infrastructure modules during immediate initialization
  boot.initrd.kernelModules = [ "nvme" "msm" "qcom-iris" ];

  # Force-compress the firmware derivation into the Stage 1 RAM disk string path
  boot.initrd.extraFirmwarePaths = [
    "${surface-firmware}"
  ];

  # Force systemd-boot to execute unified capsules (.efi) instead of broken split text configurations
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    unifiedEntries.enable = true; 
  };

  # Prevent the Snapdragon SoC from aggressively shutting down display lines before graphics load
  boot.kernelParams = [
    "earlycon=efifb"
    "video=efifb:off"
    "clk_ignore_unused"
    "pd_ignore_unused"
    "efi=debug"
    "loglevel=7"
  ];
}
