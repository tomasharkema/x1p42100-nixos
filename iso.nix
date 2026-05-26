{
  pkgs,
  lib,
  ...
}: {
  boot = {
    blacklistedKernelModules = ["qcom_q6v5_pas"];
    supportedFilesystems = {
      zfs = lib.mkForce false;
      cifs = lib.mkForce false;
    };
  };

  hardware = {
    enableAllHardware = lib.mkForce false;
    enableRedistributableFirmware = lib.mkForce false;
    firmware = with pkgs; [
      linux-firmware
      wireless-regdb
      (pkgs.callPackage ./modules/firmware.nix {})
    ];
  };

  # Ensure firmware is copied to ISO root
  environment.etc = {
    "firmware".source = "${lib.makeSearchPath "lib/firmware" (with pkgs; [
      linux-firmware
      wireless-regdb
      (pkgs.callPackage ./modules/firmware.nix {})
    ])}";
  };

  isoImage = {
    forceTextMode = true;
    squashfsCompression = "zstd";
    # Ensure firmware files are included in the squashfs
    contents = [
      {
        source = "${pkgs.callPackage ./modules/firmware.nix {}}/lib/firmware";
        target = "/lib/firmware";
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
}
